//
//  PlayHistoryRepositoryProtocol.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

protocol PlayHistoryRepositoryProtocol {
    func fetchAllHistories() throws -> [PlayHistory]
    func saveTournamentHistory(tournament: Tournament, winner: Candidate, matchHistory: [TournamentStepData]
    ) throws
    func saveStoryHistory(content: ContentMeta, steps: [StoryStepData], endingIndex: Int
    ) throws
}
