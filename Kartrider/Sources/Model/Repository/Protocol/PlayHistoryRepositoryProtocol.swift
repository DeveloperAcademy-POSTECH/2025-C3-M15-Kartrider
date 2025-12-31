//
//  PlayHistoryRepositoryProtocol.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

protocol PlayHistoryRepositoryProtocol {
    func saveTournamentHistory(
        context: ModelContext,
        tournament: Tournament,
        winner: Candidate,
        matchHistory: [TournamentStepData]
    ) throws
}
