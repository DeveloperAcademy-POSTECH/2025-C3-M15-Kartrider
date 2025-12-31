//
//  TournamentStep.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class TournamentStep {
    var round: Int // 몇 강인지 (8, 4, 2 == 결승 등)
    var matchIndex: Int // 해당 라운드에서 몇 번째 경기인지
    var candidateAText: String
    var candidateBText: String
    var selectedText: String
    var timestamp: Date = Date()

    @Relationship var history: PlayHistory

    init(round: Int, matchIndex: Int, candidateAText: String, candidateBText: String, selectedText: String, timestamp: Date, history: PlayHistory) {
        self.round = round
        self.matchIndex = matchIndex
        self.candidateAText = candidateAText
        self.candidateBText = candidateBText
        self.selectedText = selectedText
        self.timestamp = timestamp
        self.history = history
    }
}

