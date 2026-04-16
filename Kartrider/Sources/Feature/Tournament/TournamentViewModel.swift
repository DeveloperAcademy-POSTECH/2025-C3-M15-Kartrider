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

    // MARK: - Properties

    // 외부 의존성
    let connectManager = IosConnectManager.shared
    var ttsManager = TTSManager()

    // Repository
    private var contentRepository: ContentRepositoryProtocol?
    private var historyRepository: PlayHistoryRepositoryProtocol?

    // Combine
    private var cancellable = Set<AnyCancellable>()
    private var decisionTask: Task<Void, Never>?
    private var selectionTask: Task<Void, Never>?

    // 콘텐츠 정보
    private let tournamentId: UUID
    private var tournament: Tournament?
    let title: String

    // 토너먼트 진행 상태
    private var rounds: [[Candidate]] = []
    private var roundIndex = 0
    private var matchIndex = 0
    private var roundWinners: [Candidate] = []

    // MARK: - Published

    @Published var isFinished = false {
        didSet {
            guard isFinished else { return }
            finishTournamentAndSave()
        }
    }
    @Published var winner: Candidate?
    @Published var currentCandidates: (Candidate, Candidate)? {
        didSet {
            connectManager.selectedOption = nil
            connectManager.isTimeout = false
            connectManager.isFirstRequest = true
        }
    }
    @Published var matchHistory: [TournamentStepData] = []
    @Published var selectedOption: StoryChoiceOption? = nil
    @Published var decisionIndex = 0
    @Published var isTTSPlaying = false

    // Computed
    var currentRoundDescription: String {
        guard rounds.indices.contains(roundIndex) else { return "" }
        let count = rounds[roundIndex].count
        let roundText: String = (count == 2) ? "결승" : "\(count)강"
        let matchNumber = matchIndex + 1
        let totalMatches = count / 2
        return "\(roundText)\n\(totalMatches)개의 경기 중 \(matchNumber)번째 경기"
    }

    // MARK: - Init

    init(content: ContentMeta) {
        self.title = content.title
        self.tournamentId = content.tournament?.id ?? UUID()
        self.tournament = content.tournament

        guard let tournament = content.tournament else {
            Log.fault("TournamentViewModel 초기화 실패 — content.tournament가 nil")
            return
        }

        ttsManager.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.isTTSPlaying = (state == .playing)
            }
            .store(in: &cancellable)

        connectManager.$selectedOption
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self,
                      let option = newValue,
                      let (a, b) = currentCandidates,
                      selectedOption == nil
                else { return }

                decisionTask?.cancel()
                decisionTask = nil

                selectedOption = option
                let selected = option == .a ? a : b
                processSelection(selected)
            }
            .store(in: &cancellable)

        connectManager.$isTimeout
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.handleTimeout(newValue)
            }
            .store(in: &cancellable)
    }

    // MARK: Setup

    func configure(context: ModelContext) {
        contentRepository = ContentRepository(context: context)
        historyRepository = PlayHistoryRepository(context: context)
    }

    // MARK: Lifecycle

    deinit {
        decisionTask?.cancel()
        selectionTask?.cancel()
        cancellable.removeAll()
        ttsManager.stop()
        Log.info("TournamentViewModel deinit")
    }

    func cleanup() {
        decisionTask?.cancel()
        decisionTask = nil
        selectionTask?.cancel()
        selectionTask = nil
        ttsManager.stop()
    }

    // MARK: - Tournament Flow

    @MainActor
    func loadTournament() {
        do {
            guard let tournament = try contentRepository?.fetchTournament(by: tournamentId)
            else {
                Log.error("토너먼트 데이터 없음")
                return
            }
            self.tournament = tournament
            let shuffled = tournament.candidates.shuffled()
            rounds = [shuffled]
            isFinished = false
            winner = nil
            roundIndex = 0
            matchIndex = 0
            matchHistory = []
            prepareNextMatch()
        } catch {
            Log.error("토너먼트 로딩 실패: \(error)")
        }
    }

    @MainActor
    func prepareNextMatch() {
        let currentRound = rounds[roundIndex]
        guard matchIndex * 2 + 1 < currentRound.count else {
            // 현재 라운드 끝났으면
            if roundWinners.count == 1 {
                winner = roundWinners.first
                isFinished = true
                currentCandidates = nil
                Task { await speakTournamentEnding() }
            } else {
                // 다음 라운드 준비
                rounds.append(roundWinners)
                roundIndex += 1
                matchIndex = 0
                roundWinners = []
                prepareNextMatch()
            }
            return
        }

        let a = currentRound[matchIndex * 2]
        let b = currentRound[matchIndex * 2 + 1]
        currentCandidates = (a, b)
    }

    @MainActor
    func select(_ selected: Candidate) {
        guard let (a, b) = currentCandidates else { return }

        let step = TournamentStepData(
            round: rounds[roundIndex].count,
            matchIndex: matchIndex,
            candidateAText: a.name,
            candidateBText: b.name,
            selectedText: selected.name,
            timestamp: Date()
        )
        matchHistory.append(step)
        roundWinners.append(selected)
        matchIndex += 1
        prepareNextMatch()
        selectedOption = nil
    }

    // MARK: - Selection

    func processSelection(_ candidate: Candidate) {
        selectionTask?.cancel()

        selectionTask = Task { [weak self] in
            guard let self else { return }

            guard !Task.isCancelled else { return }

            ttsManager.stop()
            connectManager.sendChoiceInterrupt()

            guard !Task.isCancelled else { return }
            await speakSelectedChoice(candidate)

            guard !Task.isCancelled else { return }
            try? await Task.sleep(nanoseconds: 200_000_000)

            guard !Task.isCancelled else { return }
            await select(candidate)

            await MainActor.run {
                self.decisionIndex += 1
            }

            guard !Task.isCancelled else { return }
            await speakMatchIntro()
        }
    }

    func handleTimeout(_ newValue: Bool?) {
        let isTimeout = newValue == true
        let sameIndex = connectManager.decisionIndex == decisionIndex
        let noSelection = selectedOption == nil

        guard isTimeout, sameIndex, noSelection else { return }

        if connectManager.isFirstRequest {
            speakSecondDecision()
        } else {
            if let (aCandidate, _) = currentCandidates {
                selectedOption = .a
                processSelection(aCandidate)
            }
        }
        connectManager.isTimeout = false
    }

    // MARK: - TTS

    @MainActor
    func speakMatchIntro() {
        guard let (a, b) = currentCandidates else { return }

        decisionTask?.cancel()

        connectManager.isTimeout = false
        connectManager.isFirstRequest = true

        decisionTask = Task { [weak self] in
            guard let self else { return }

            connectManager.sendStageDecision(decisionIndex: decisionIndex, isTimerRunning: false, isFirstRequest: true)
            await ttsManager.speakSequentially(currentRoundDescription)
            await ttsManager.speakSequentially("A. \(a.name)")
            await ttsManager.speakSequentially("B. \(b.name)")
            connectManager.sendStageDecision(decisionIndex: decisionIndex, isTimerRunning: true, isFirstRequest: true)
        }
    }

    func speakSecondDecision() {
        guard let (a, b) = currentCandidates else { return }
        decisionTask?.cancel()

        let texts = [
            "선택지가 다시 한번 재생됩니다",
            "A. \(a.name)",
            "B. \(b.name)",
        ]

        decisionTask = Task { [weak self] in
            guard let self else { return }

            connectManager.sendStageDecision(decisionIndex: decisionIndex, isTimerRunning: false, isFirstRequest: false)
            for text in texts {
                await ttsManager.speakSequentially(text)
            }
            connectManager.sendStageDecision(decisionIndex: decisionIndex, isTimerRunning: true, isFirstRequest: false)
        }
    }

    func speakSelectedChoice(_ candidate: Candidate) async {
        await ttsManager.speakSequentially("\(candidate.name) 선택")
    }

    @MainActor
    func speakTournamentEnding() async {
        connectManager.sendStageEnding(isTimerRunning: false)

        guard let winner else { return }

        ttsManager.stop()
        try? await Task.sleep(nanoseconds: 300_000_000)
        await ttsManager.speakSequentially("최종 우승자는 \(winner.name)입니다")
        connectManager.sendStageEnding(isTimerRunning: true)
    }

    func toggleSpeaking() {
        if isTTSPlaying {
            connectManager.sendStageExposition(isTTSPlaying: false)
        } else {
            connectManager.sendStageExposition(isTTSPlaying: true)
        }
        ttsManager.toggleSpeaking()
    }

    // MARK: - History

    func finishTournamentAndSave() {
        guard let winner = winner, let tournament = tournament else { return }
        do {
            try historyRepository?.saveTournamentHistory(
                tournament: tournament,
                winner: winner,
                matchHistory: matchHistory
            )
        } catch {
            Log.error("토너먼트 히스토리 저장 실패: \(error)")
        }
    }
}
