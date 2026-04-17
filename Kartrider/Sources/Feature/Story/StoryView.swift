//
//  StoryView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//
import SwiftUI

struct StoryView: View {
    @Environment(\.modelContext) private var context

    @EnvironmentObject private var coordinator: NavigationCoordinator
    @StateObject private var storyViewModel: StoryViewModel

    init(content: ContentMeta) {
        _storyViewModel = StateObject(
            wrappedValue: StoryViewModel(content: content)
        )
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.play(
                title: storyViewModel.content.title),
            onTapLeft: {
                storyViewModel.cleanup()
                coordinator.pop()
            }
        ) {
            VStack(spacing: 16) {
                Divider()
                if storyViewModel.isLoading {
                    DescriptionBoxView(
                        text: storyViewModel.currentNode?.text ?? "")
                    Spacer()
                } else if let errorMessage = storyViewModel.errorMessage {
                    Text(errorMessage)
                } else if let storyNode = storyViewModel.currentNode {
                    VStack {

                        DescriptionBoxView(text: storyNode.text)

                        StoryNodeContentView(
                            storyNode: storyNode,
                            isDisabled: storyViewModel.isSequenceInProgress,
                            selectChoice: storyViewModel.selectChoice(
                                toId:),
                            title: storyViewModel.content.title
                        )

                        Spacer()

                        TTSControlButton(
                            isSpeaking: storyViewModel.isTTSPlaying
                        ) {
                            storyViewModel.toggleSpeaking()
                        }
                        .disabled(
                            storyViewModel.isTransitioningTTS
                                || storyViewModel.isTogglingTTS)
                    }
                    .contentShape(Rectangle())
                }

            }
        }
        .task {
            storyViewModel.configure(context: context)
            await storyViewModel.loadInitialNode()
        }
        .onChange(of: storyViewModel.currentNode) { _, newNode in
            guard let storyNode = newNode else { return }
            guard !storyViewModel.isSequenceInProgress else { return }
            Task {
                await MainActor.run { storyViewModel.isSequenceInProgress = true }
                try? await Task.sleep(for: .milliseconds(300))
                await storyViewModel.processNode(storyNode)
            }
        }
    }
}

#Preview("선택 노드") {
    let helper = PreviewHelper()
    let meta = helper.makeStoryMeta()
    let story = helper.makeStory(meta: meta)
    try? helper.context.save()

    let node = story.nodes.first(where: { $0.type == .decision })!
    return DecisionNodeView(
        storyNode: node,
        isDisabled: false,
        selectChoice: { _ in }
    )
    .modelContainer(helper.container)
}

#Preview("결말 노드") {
    EndingNodeView(title: "조용한 기다림")
}

#Preview("텍스트 박스") {
    DescriptionBoxView(text: "지유가 차에 탔다. 현우 선배를 발견했다.")
}
