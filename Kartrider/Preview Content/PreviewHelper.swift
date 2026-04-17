//
//  PreviewHelper.swift
//  Kartrider
//
//  Created by J on 4/17/26.
//

import SwiftData
import SwiftUI

@MainActor
struct PreviewHelper {

    let container: ModelContainer
    let context: ModelContext

    init() {
        let schema = Schema([
            ContentMeta.self, Story.self, StoryNode.self,
            StoryChoice.self, EndingCondition.self, Hashtag.self,
            Tournament.self, Candidate.self, PlayHistory.self,
            StoryStep.self, TournamentStep.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
    }

    // MARK: - ContentMeta

    func makeStoryMeta(
        title: String = "눈 떠보니 내가 T1 페이커?!",
        summary: String = "아이언인 내가 페이커 몸에 들어와버렸다.",
        hashtags: [String] = ["빙의", "LOL"]
    ) -> ContentMeta {
        let meta = ContentMeta(
            title: title,
            summary: summary,
            type: .story,
            hashtags: hashtags.map { Hashtag(value: $0) },
            thumbnailName: nil
        )
        context.insert(meta)
        return meta
    }

    func makeTournamentMeta(
        title: String = "간식 월드컵",
        summary: String = "가장 좋아하는 간식을 골라보세요!",
        hashtags: [String] = ["간식", "월드컵"]
    ) -> ContentMeta {
        let meta = ContentMeta(
            title: title,
            summary: summary,
            type: .tournament,
            hashtags: hashtags.map { Hashtag(value: $0) },
            thumbnailName: nil
        )
        context.insert(meta)
        return meta
    }

    // MARK: - Story

    @discardableResult
    func makeStory(meta: ContentMeta) -> Story {
        let story = Story(startNodeId: "node1", meta: meta)
        context.insert(story)

        let node1 = StoryNode(id: "node1", text: "지유가 차에 탔다.", type: .exposition, nextId: "node2", story: story)
        let node2 = StoryNode(id: "node2", text: "말을 걸까, 말까?", type: .decision, story: story)
        let choiceA = StoryChoice(text: "말을 건다", toId: "end1")
        let choiceB = StoryChoice(text: "그냥 지나친다", toId: "end1")
        node2.choiceA = choiceA
        node2.choiceB = choiceB
        let ending = StoryNode(id: "end1", text: "결말입니다.", type: .ending, endingIndex: 1, title: "조용한 기다림", story: story)

        let endingConditionA = EndingCondition(pathString: "A", toId: "end1")
        endingConditionA.story = story
        let endingConditionB = EndingCondition(pathString: "B", toId: "end1")
        endingConditionB.story = story

        [node1, node2, ending].forEach { context.insert($0) }
        context.insert(choiceA)
        context.insert(choiceB)
        context.insert(endingConditionA)
        context.insert(endingConditionB)
        try? context.save()
        return story
    }

    // MARK: - Tournament

    @discardableResult
    func makeTournament(
        meta: ContentMeta,
        candidateNames: [String] = ["아이스크림", "초콜릿", "과자", "젤리"]
    ) -> Tournament {
        let tournament = Tournament(meta: meta)
        context.insert(tournament)

        for name in candidateNames {
            let candidate = Candidate(name: name, tournament: tournament)
            context.insert(candidate)
            tournament.candidates.append(candidate)
        }

        try? context.save()
        return tournament
    }

    // MARK: - PlayHistory

    @discardableResult
    func makeStoryHistory(meta: ContentMeta, endingIndex: Int = 1) -> PlayHistory {
        let history = PlayHistory(content: meta)
        history.endedAt = Date()
        history.reachedEndingIndex = endingIndex
        context.insert(history)
        return history
    }

    @discardableResult
    func makeTournamentHistory(meta: ContentMeta, winner: Candidate) -> PlayHistory {
        let history = PlayHistory(content: meta)
        history.endedAt = Date()
        history.winningCandidateId = winner.id
        context.insert(history)
        return history
    }
}
