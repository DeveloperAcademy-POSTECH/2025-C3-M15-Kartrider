import Combine

//
//  StoryViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//
import Foundation
import SwiftData

class StoryViewModel: ObservableObject {

    let connectManager = IosConnectManager.shared
    private var contentRepository: ContentRepositoryProtocol?
    private var historyRepository: PlayHistoryRepositoryProtocol?

    private var cancellable = Set<AnyCancellable>()

    let content: ContentMeta
    let startNodeId: String
    private var stepHistory: [StoryStepData] = []
    private var lastToggleTime: Date = .distantPast

    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var currentNode: StoryNode?
    @Published var isSequenceInProgress = false
    @Published var selectedPath: [StoryChoiceOption] = []
    @Published var endingId: String = ""
    @Published var isTTSPlaying = false
    @Published var isTogglingTTS = false
    @Published var isTransitioningTTS = false

    @Published var decisionIndex = 0
    private var secPlayed = false
    private var decisionTask: Task<Void, Never>?
    private var nodeHandlingTask: Task<Void, Never>?

    var ttsManager = TTSManager()

    func configure(context: ModelContext) {
        contentRepository = ContentRepository(context: context)
        historyRepository = PlayHistoryRepository(context: context)
    }

    init(content: ContentMeta) {
        self.content = content
        startNodeId = content.story?.startNodeId ?? ""

        ttsManager.didSpeakingStateChanged = { [weak self] speaking in
            DispatchQueue.main.async {
                self?.isTTSPlaying = speaking
                self?.isTogglingTTS = false
            }
        }

        connectManager.$isTTSPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                if newValue == isTTSPlaying { return }

                if newValue {
                    ttsManager.resume()
                } else {
                    ttsManager.pause()
                }
                isTTSPlaying = newValue
            }
            .store(in: &cancellable)

        connectManager.$selectedOption
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self, let selected = newValue else { return }
                Log.debug("워치 선택 감지: \(selected.rawValue)")
                handleWatchChoice(option: selected)
                connectManager.selectedOption = nil
            }
            .store(in: &cancellable)

        connectManager.$isTimeout
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.handleTimeout(newValue)
            }
            .store(in: &cancellable)
    }

    deinit {
        decisionTask?.cancel()
        nodeHandlingTask?.cancel()
        cancellable.removeAll()
        ttsManager.stop()
        Log.info("StoryViewModel deinit")
    }

    func cleanup() {
        decisionTask?.cancel()
        decisionTask = nil
        nodeHandlingTask?.cancel()
        nodeHandlingTask = nil
        ttsManager.stop()
    }

    @MainActor
    func loadInitialNode() async {
        isLoading = true
        errorMessage = nil
        do {
            if let storyId = content.story?.id,
               let story = try contentRepository?.fetchStory(by: storyId),
               let node = story.nodes.first(where: { $0.id == startNodeId })
            {
                currentNode = node
                await handleStoryNode(node)
            } else {
                errorMessage = "해당 스토리를 찾을 수 없습니다"
            }
        } catch {
            errorMessage = "스토리 로딩 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func goToNextNode(from currentNode: StoryNode) {
        guard let nextId = currentNode.nextId,
              let story = currentNode.story,
              let nextNode = story.nodes.first(where: { $0.id == nextId })
        else {
            errorMessage = "다음 스토리 노드를 찾을 수 없습니다"
            return
        }

        Task { @MainActor in
            self.currentNode = nextNode
        }
    }

    func selectChoice(toId: String) {
        guard let currentNode,
              let story = currentNode.story,
              let nextNode = story.nodes.first(where: { $0.id == toId })
        else { return }

        let selectedChoice: StoryChoiceOption
        var selectedText: String = ""

        if let choice = currentNode.choiceA, choice.toId == toId {
            selectedPath.append(.a)
            selectedChoice = .a
            selectedText = choice.text
        } else if let choice = currentNode.choiceB, choice.toId == toId {
            selectedPath.append(.b)
            selectedChoice = .b
            selectedText = choice.text
        } else {
            return
        }

        stepHistory.append(StoryStepData(
            nodeId: currentNode.id,
            type: currentNode.type,
            nodeText: currentNode.text,
            selectedChoice: selectedChoice,
            selectedText: selectedText,
            timestamp: Date()
        ))

        self.currentNode = nextNode
        self.decisionIndex += 1
    }

    @MainActor
    func handleStoryNode(_ node: StoryNode) async {
        nodeHandlingTask?.cancel()

        nodeHandlingTask = Task { [weak self] in
            guard let self else { return }

            isSequenceInProgress = true

            if node.type == .decision {
                guard !Task.isCancelled else { return }
                connectManager.isTimeout = false
                connectManager.isFirstRequest = true
                secPlayed = false
                firstDecision(node: node)

            } else if node.nextId == nil {
                guard !Task.isCancelled else { return }
                endingId = checkEndingCondition()
                await goToEndingNode(toId: endingId)

            } else if node.type == .exposition {
                stepHistory.append(StoryStepData(
                    nodeId: node.id,
                    type: node.type,
                    nodeText: node.text,
                    selectedChoice: nil,
                    selectedText: nil,
                    timestamp: Date()
                ))
                connectManager.sendStageExpositionWithResume()
                await ttsManager.speakSequentially(node.text)
                self.goToNextNode(from: node)
            }

            isSequenceInProgress = false
        }
    }

    private func checkEndingCondition() -> String {
        guard let story = currentNode?.story else { return "" }

        for condition in story.endingConditions {
            if condition.path == selectedPath {
                Log.info("일치하는 엔딩 도달: \(condition.toId)")
                return condition.toId
            }
        }
        return ""
    }

    @MainActor
    private func goToEndingNode(toId: String) async {
        isLoading = true
        do {
            if let storyId = content.story?.id,
               let story = try contentRepository?.fetchStory(by: storyId),
               let endingNode = story.nodes.first(where: { $0.id == toId })
            {
                stepHistory.append(StoryStepData(
                    nodeId: endingNode.id,
                    type: endingNode.type,
                    nodeText: endingNode.text,
                    selectedChoice: nil,
                    selectedText: nil,
                    timestamp: Date()
                ))

                if let endingIndex = endingNode.endingIndex {
                    try historyRepository?.saveStoryHistory(
                        content: content,
                        steps: stepHistory,
                        endingIndex: endingIndex
                    )
                }

                currentNode = endingNode
                connectManager.sendStageEndingTTS()
                if !endingNode.text.isEmpty {
                    await ttsManager.speakSequentially(endingNode.text)
                }
                connectManager.sendStageEndingTimer()
            } else {
                errorMessage = "해당 결말을 찾을 수 없습니다"
            }
        } catch {
            errorMessage = "스토리 로딩 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func toggleSpeaking() {
        if isTogglingTTS {
            Log.debug("잠시 토글 비활성화중")
            return
        }
        isTogglingTTS = true

        if isTTSPlaying {
            connectManager.sendStageExpositionWithPause()
        } else {
            connectManager.sendStageExpositionWithResume()
        }

        ttsManager.toggleSpeaking()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isTogglingTTS = false
        }
    }

    func handleWatchChoice(option: StoryChoiceOption) {
        guard let currentNode else { return }
        connectManager.sendChoiceInterrupt()

        switch option {
        case .a:
            if let toId = currentNode.choiceA?.toId {
                selectChoice(toId: toId)
            }

        case .b:
            if let toId = currentNode.choiceB?.toId {
                selectChoice(toId: toId)
            }
        }
    }

    func firstDecision(node: StoryNode) {
        decisionTask?.cancel()
        decisionTask = Task { [weak self] in
            guard let self else { return }

            connectManager.sendStageDecisionWithFirstTTS(decisionIndex)
            if !node.text.isEmpty {
                await ttsManager.speakSequentially(node.text)
            }
            await ttsManager.speakSequentially("A")
            await ttsManager.speakSequentially(node.choiceA?.text ?? "")
            await ttsManager.speakSequentially("B")
            await ttsManager.speakSequentially(node.choiceB?.text ?? "")

            connectManager.sendStageDecisionWithFirstTimer(decisionIndex)
        }
    }

    func playSecDecisionTTS(node: StoryNode) {
        decisionTask?.cancel()
        secPlayed = true

        let texts = [
            "선택지가 다시 한번 재생됩니다",
            "A. \(node.choiceA?.text ?? "")",
            "B. \(node.choiceB?.text ?? "")",
        ]

        decisionTask = Task { [weak self] in
            guard let self else { return }

            secPlayed = true
            connectManager.sendStageDecisionWithSecTTS(decisionIndex)
            for text in texts {
                await ttsManager.speakSequentially(text)
            }
            connectManager.sendStageDecisionWithSecTimer(decisionIndex)
        }
    }

    func handleTimeout(_ newValue: Bool?) {
        let isTimeout = newValue == true
        let noSelection = connectManager.selectedOption == nil
        guard isTimeout, noSelection,
              let node = currentNode, node.type == .decision
        else { return }

        if connectManager.isFirstRequest == true {
            playSecDecisionTTS(node: node)
            connectManager.isFirstRequest = false
        } else {
            if let toId = node.choiceA?.toId {
                selectChoice(toId: toId)
            }
        }
        connectManager.isTimeout = false
    }
}
