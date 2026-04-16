//
//  PlayHistoryRepository.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

class PlayHistoryRepository: PlayHistoryRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAllHistories() throws -> [PlayHistory] {
        let descriptor = FetchDescriptor<PlayHistory>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func saveTournamentHistory(tournament: Tournament, winner: Candidate, matchHistory: [TournamentStepData]) throws {
        let history = PlayHistory(content: tournament.meta)
        history.endedAt = Date()
        history.winningCandidateId = winner.id
        context.insert(history)
        
        for step in matchHistory {
            let tournamentStep = TournamentStep(
                round: step.round,
                matchIndex: step.matchIndex,
                candidateAText: step.candidateAText,
                candidateBText: step.candidateBText,
                selectedText: step.selectedText,
                timestamp: step.timestamp,
                history: history
            )
            context.insert(tournamentStep)
        }
        
        try context.save()
    }

    func saveStoryHistory(content: ContentMeta, steps: [StoryStepData], endingIndex: Int) throws {
        let history = PlayHistory(content: content)
        history.endedAt = Date()
        history.reachedEndingIndex = endingIndex
        context.insert(history)

        for step in steps {
            let storyStep = StoryStep(
                nodeId: step.nodeId,
                type: step.type,
                nodeText: step.nodeText,
                selectedChoice: step.selectedChoice,
                selectedText: step.selectedText,
                timestamp: step.timestamp,
                history: history
            )
            context.insert(storyStep)
        }

        try context.save()
    }
}
