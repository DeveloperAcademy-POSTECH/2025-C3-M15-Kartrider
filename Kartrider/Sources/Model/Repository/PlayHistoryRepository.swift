//
//  PlayHistoryRepository.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

class PlayHistoryRepository: PlayHistoryRepositoryProtocol {
    
    func saveTournamentHistory(
        context: ModelContext,
        tournament: Tournament,
        winner: Candidate,
        matchHistory: [TournamentStepData]
    ) throws {
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
}
