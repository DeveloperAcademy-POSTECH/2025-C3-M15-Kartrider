//
//  PlayHistoryRepositoryProtocol.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

protocol PlayHistoryRepositoryProtocol {
    func saveTournamentHistory(tournament: Tournament, winner: Candidate, matchHistory: [TournamentStepData]
    ) throws
}
