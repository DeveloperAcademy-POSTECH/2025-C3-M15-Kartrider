//
//  TournamentViewModel.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import Combine
import Foundation
import SwiftData

class TournamentViewModel: ObservableObject {

    let connectManager = IosConnectManager.shared

    private var cancellable = Set<AnyCancellable>()
    private var context: ModelContext?

    @Published var matchHistory: [TournamentStepData] = []
    @Published var isTTSPlaying = false
    @Published var title: String
    @Published var currentCandidates: (Candidate, Candidate)? {
        didSet {
            connectManager.selectedOption = nil
            connectManager.isTimeout = false
            connectManager.isFirstRequest = true
        }
    }
    
    @Published var isFinished = false {
        didSet {
            guard isFinished, let context = context else { return }
            finishTournamentAndSave(context: context)
        }
    }
    
    @Published var winner: Candidate? {
        didSet {
            Task {
                await handleTournamentEndingTTS()
            }
        }
    }
    
    private let contentRepository: ContentRepositoryProtocol
    private let historyRepository: PlayHistoryRepositoryProtocol
    private let tournamentId: UUID
    private var tournament: Tournament?
    private var nextRoundCandidates: [Candidate] = []
    private var rounds: [[Candidate]] = []
    private var currentRoundIndex = 0  // 지금 몇 라운드인지 ex. 8강, 4강, 결승
    private var currentMatchIndex = 0  // 지금 라운드에서 몇번째 매치인지

    var currentRoundDescription: String {
        guard rounds.indices.contains(currentRoundIndex) else { return "" }
        let count = rounds[currentRoundIndex].count
        let roundText: String = (count == 2) ? "결승" : "\(count)강"
        let matchNumber = currentMatchIndex + 1
        let totalMatches = count / 2
        return "\(roundText)\n\(totalMatches)개의 경기 중 \(matchNumber)번째 경기"
    }
    
    @Published var selectedOption: StoryChoiceOption? = nil
    @Published var decisionIndex = 0
    @Published var decisionTask: Task<Void, Never>? = nil

    var ttsManager = TTSManager()

    init(
        content: ContentMeta,
        contentRepository: ContentRepositoryProtocol = ContentRepository(),
        historyRepository: PlayHistoryRepositoryProtocol =
            PlayHistoryRepository()
    ) {
        self.tournament = content.tournament
        self.tournamentId = content.tournament!.id
        self.contentRepository = contentRepository
        self.historyRepository = historyRepository
        self.title = content.title

        connectManager.$selectedOption
            .receive(on: DispatchQueue.main)
            .sink { newValue in
                guard let option = newValue,
                    let (a, b) = self.currentCandidates,
                    self.selectedOption == nil
                else { return }

                self.decisionTask?.cancel()
                self.decisionTask = nil

                self.selectedOption = option
                let selected = option == .a ? a : b
                self.handleSelection(selected)
            }
            .store(in: &cancellable)

        connectManager.$isTimeout
            .receive(on: DispatchQueue.main)
            .sink { newValue in
                self.handleTimeout(newValue)
            }
            .store(in: &cancellable)

    }
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }

    @MainActor
    func loadTournament(context: ModelContext) {
        do {
            guard
                let tournament = try contentRepository.fetchTournament(
                    by: tournamentId, context: context)
            else {
                print("[ERROR] 토너먼트 찾을 수 없음")
                return
            }
            self.tournament = tournament
            let shuffled = tournament.candidates.shuffled()
            rounds = [shuffled]
            isFinished = false
            winner = nil
            currentRoundIndex = 0
            currentMatchIndex = 0
            matchHistory = []
            prepareNextMatch()
        } catch {
            print("[ERROR] 토너먼트 로딩 실패 : \(error)")
        }
    }

    @MainActor
    func prepareNextMatch() {
        let currentRound = rounds[currentRoundIndex]
        guard currentMatchIndex * 2 + 1 < currentRound.count else {
            // 현재 라운드 끝났으면
            if nextRoundCandidates.count == 1 {
                winner = nextRoundCandidates.first
                isFinished = true
                currentCandidates = nil
            } else {
                // 다음 라운드 준비
                rounds.append(nextRoundCandidates)
                currentRoundIndex += 1
                currentMatchIndex = 0
                nextRoundCandidates = []
                prepareNextMatch()
            }
            return
        }

        let a = currentRound[currentMatchIndex * 2]
        let b = currentRound[currentMatchIndex * 2 + 1]
        currentCandidates = (a, b)
    }
    
    @MainActor
    func select(_ selected: Candidate) {
        guard let (a, b) = currentCandidates else { return }

        let step = TournamentStepData(
            round: rounds[currentRoundIndex].count,
            matchIndex: currentMatchIndex,
            candidateAText: a.name,
            candidateBText: b.name,
            selectedText: selected.name,
            timestamp: Date()
        )
        matchHistory.append(step)
        nextRoundCandidates.append(selected)
        currentMatchIndex += 1
        prepareNextMatch()
        selectedOption = nil
    }

    private func makeNextRound(from round: [Candidate]) -> [Candidate] {
        return round
    }

    func finishTournamentAndSave(context: ModelContext) {
        guard let winner = winner else { return }
        do {
            try historyRepository.saveTournamentHistory(
                context: context,
                tournament: tournament!,
                winner: winner,
                matchHistory: matchHistory
            )
        } catch {
            print("[ERROR] 토너먼트 히스토리 저장 실패 : \(error)")
        }
    }

    func handleSelection(_ candidate: Candidate) {
        Task {
            // TODO: ttsManager.stop : Async함수 아님
            ttsManager.stop()
            connectManager.sendChoiceInterrupt()
            await speakSelectedChoice(candidate)
            try? await Task.sleep(nanoseconds: 200_000_000)

            await select(candidate)
            await MainActor.run {
                self.decisionIndex += 1
            }
            await speakCurrentMatch()
        }
    }
    
    @MainActor
    func speakCurrentMatch() {
        guard let (a, b) = currentCandidates else { return }

        decisionTask?.cancel()

        connectManager.isTimeout = false
        connectManager.isFirstRequest = true

        decisionTask = Task {
            connectManager.sendStageDecisionWithFirstTTS(
                decisionIndex)
            await MainActor.run { self.isTTSPlaying = true }
            await ttsManager.speakSequentially(currentRoundDescription)
            await ttsManager.speakSequentially("A. \(a.name)")
            await ttsManager.speakSequentially("B. \(b.name)")
            await MainActor.run { self.isTTSPlaying = false }
            connectManager.sendStageDecisionWithFirstTimer(
                decisionIndex)
        }
    }

    func playSecondTTS() { 
        guard let (a, b) = currentCandidates else { return }
        decisionTask?.cancel()

        let texts = [
            "선택지가 다시 한번 재생됩니다",
            "A. \(a.name)",
            "B. \(b.name)",
        ]

        decisionTask = Task {
            connectManager.sendStageDecisionWithSecTTS(decisionIndex)
            await MainActor.run { self.isTTSPlaying = true }
            for text in texts { await ttsManager.speakSequentially(text) }
            await MainActor.run { self.isTTSPlaying = false }
            connectManager.sendStageDecisionWithSecTimer(decisionIndex)
        }
    }

    func speakSelectedChoice(_ candidate: Candidate) async {
        await ttsManager.speakSequentially("\(candidate.name) 선택")
    }

    func handleTimeout(_ newValue: Bool?) {
        let isTimeout = newValue == true
        let sameIndex = connectManager.decisionIndex == decisionIndex
        let noSelection = selectedOption == nil

        guard isTimeout, sameIndex, noSelection else { return }

        if connectManager.isFirstRequest {
            playSecondTTS()
        } else {
            if let (aCandidate, _) = currentCandidates {
                selectedOption = .a
                handleSelection(aCandidate)
            }
        }
        connectManager.isTimeout = false
    }

    @MainActor
    func handleTournamentEndingTTS() async {
        connectManager.sendStageEndingTTS()
        
        guard let winner = self.winner else { return }
        
        isTTSPlaying = true
        ttsManager.stop()
        try? await Task.sleep(nanoseconds: 300_000_000)
        await ttsManager.speakSequentially("최종 우승자는 \(winner.name)입니다")
        connectManager.sendStageEndingTimer()
        isTTSPlaying = false
    }
}
