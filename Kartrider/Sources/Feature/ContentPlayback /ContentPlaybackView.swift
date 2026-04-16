//
//  EndingDetailView.swift
//  Kartrider
//
//  Created by 박난 on 5/28/25.
//

import SwiftUI
import SwiftData

struct ContentPlaybackView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @StateObject private var viewModel: ContentPlaybackViewModel

    init(history: PlayHistory) {
        _viewModel = StateObject(wrappedValue: ContentPlaybackViewModel(history: history))
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: .historyDetail,
            onTapLeft: { coordinator.pop() }
        ) {
            ScrollView {
                VStack(spacing: 0) {
                    headerView

                    Divider()

                    switch viewModel.contentType {
                    case .story:
                        storyBody
                    case .tournament:
                        tournamentBody
                    }
                }
            }
        }
    }

    // MARK: 공통 헤더
    private var headerView: some View {
        ZStack(alignment: .bottomLeading) {
            // 썸네일 배경
            Group {
                if let thumbnailName = viewModel.thumbnailName {
                    Image(thumbnailName)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(height: 220)
            .clipped()

            // 그라데이션
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)

            // 텍스트
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                HStack(spacing: 16) {
                    LabeledContent("결말 제목") {
                        Text(viewModel.contentType == .story
                             ? viewModel.endingTitle
                             : viewModel.winnerName)
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("플레이 날짜") {
                        Text(viewModel.formattedDate)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
            }
            .padding(16)
        }
    }

    // MARK: 스토리 바디
    private var storyBody: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 결말 요약 박스
            VStack(alignment: .leading, spacing: 8) {
                Text("결말 요약")
                    .font(.caption.bold())
                    .foregroundStyle(Color.primaryOrange)
                Text(viewModel.endingText)
                    .font(.body)
                    .foregroundStyle(Color.primaryOrange)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.primaryOrange.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 16)

            // 다시보기 섹션
            Text("다시보기")
                .font(.title3.bold())
                .padding(.horizontal, 16)

            ForEach(viewModel.storySteps) { step in
                StoryStepRowView(step: step)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 20)
    }

    // MARK: 토너먼트 바디
    private var tournamentBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 선택 횟수 박스
            HStack(spacing: 12) {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundStyle(Color.primaryOrange)
                Text("이번 게임에서는 \(viewModel.totalSelectionCount)번의 선택을 했어요\n선택들이 모여 우승자가 나왔습니다!")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.primaryOrange)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.primaryOrange.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 16)

            // 결말 박스
            VStack(alignment: .leading, spacing: 8) {
                Text("결말")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("최종 우승자는 \(viewModel.winnerName) 입니다!")
                    .font(.body)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 16)

            // 전체 이야기 보기 버튼 (토너먼트 선택 흐름)
            OrangeButton(title: "전체 이야기 보기") {
                // TODO: 토너먼트 선택 흐름 상세 화면
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 20)
    }
}

#Preview("스토리") {
    let schema = Schema([
        ContentMeta.self, PlayHistory.self, Story.self,
        StoryNode.self, StoryChoice.self, EndingCondition.self,
        Tournament.self, Candidate.self, StoryStep.self,
        TournamentStep.self, Hashtag.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext

    let hashtags = [Hashtag(value: "시대"), Hashtag(value: "장르")]
    let meta = ContentMeta(
        title: "진격의 거인",
        summary: "summary",
        type: .story,
        hashtags: hashtags,
        thumbnailName: nil
    )
    context.insert(meta)

    let story = Story(startNodeId: "node1", meta: meta)
    context.insert(story)

    let node1 = StoryNode(id: "node1", text: "지유 (차에 타며)\n\"어... 혹시... 현우 선배 아니에요?\"", type: .exposition, nextId: "node2", story: story)
    let node2 = StoryNode(id: "node2", text: "말할까, 말까?", type: .decision, story: story)
    let ending = StoryNode(id: "end1", text: "에렌 예거는 인류를 위협하는 마레 제국과 싸웠다.", type: .ending, endingIndex: 1, title: "조용한 기다림", story: story)
    [node1, node2, ending].forEach { context.insert($0) }

    let history = PlayHistory(content: meta)
    history.endedAt = Date()
    history.reachedEndingIndex = 1
    context.insert(history)

    let step1 = StoryStep(nodeId: "node1", type: .exposition, nodeText: node1.text, timestamp: Date(), history: history)
    let step2 = StoryStep(nodeId: "node2", type: .decision, nodeText: node2.text, selectedChoice: .b, selectedText: "어디 가세요?", timestamp: Date(), history: history)
    [step1, step2].forEach { _ in context.insert(step2) }

    return ContentPlaybackView(history: history)
        .modelContainer(container)
        .environmentObject(NavigationCoordinator())
}

#Preview("토너먼트") {
    let schema = Schema([
        ContentMeta.self, PlayHistory.self, Story.self,
        StoryNode.self, StoryChoice.self, EndingCondition.self,
        Tournament.self, Candidate.self, StoryStep.self,
        TournamentStep.self, Hashtag.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext

    let meta = ContentMeta(
        title: "간식 월드컵 게임",
        summary: "summary",
        type: .tournament,
        hashtags: [],
        thumbnailName: nil
    )
    context.insert(meta)

    let tournament = Tournament(meta: meta)
    context.insert(tournament)

    let winner = Candidate(name: "아이스크림", tournament: tournament)
    context.insert(winner)

    let history = PlayHistory(content: meta)
    history.endedAt = Date()
    history.winningCandidateId = winner.id
    context.insert(history)

    for i in 1...10 {
        let step = TournamentStep(
            round: i,
            matchIndex: i - 1,
            candidateAText: "후보 A",
            candidateBText: "후보 B",
            selectedText: "아이스크림",
            timestamp: Date(),
            history: history
        )
        context.insert(step)
    }

    return ContentPlaybackView(history: history)
        .modelContainer(container)
        .environmentObject(NavigationCoordinator())
}
