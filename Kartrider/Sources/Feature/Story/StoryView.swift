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
                storyViewModel.ttsManager.pause()
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
                        // TODO: ViewModel로 분리
                        .disabled(
                            storyViewModel.isTransitioningTTS
                                || storyViewModel.isTogglingTTS)
                    }
                    .contentShape(Rectangle())
                }

            }
        }
        .task {
            await storyViewModel.loadInitialNode(context: context)
        }
        .onChange(of: storyViewModel.currentNode) { _, newNode in
            guard let storyNode = newNode else { return }
            guard !storyViewModel.isSequenceInProgress else { return }

            Task {
                await MainActor.run {
                    storyViewModel.isSequenceInProgress = true
                }
                try? await Task.sleep(for: .milliseconds(300))
                await storyViewModel.handleStoryNode(
                    storyNode, context: context)
            }
        }
    }

    #Preview {
        let contentSample = ContentMeta(
            title: "title sample",
            summary: "summary sample",
            type: .story,
            hashtags: [
                Hashtag(value: "빙의"),
                Hashtag(value: "LOL"),
            ],
            thumbnailName: nil
        )
        StoryView(content: contentSample)
    }
}
