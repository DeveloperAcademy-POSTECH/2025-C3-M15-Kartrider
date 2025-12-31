//
//  PlayHistory.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class PlayHistory {
    @Attribute(.unique) var id: UUID
    
    var startedAt: Date
    var endedAt: Date?
    
    var reachedEndingIndex: Int?
    var winningCandidateId: UUID?
    
    @Relationship var content: ContentMeta
    @Relationship(deleteRule: .cascade, inverse: \StoryStep.history) var storySteps: [StoryStep] = []
    @Relationship(deleteRule: .cascade) var tournamentSteps: [TournamentStep] = []
    
    init(content: ContentMeta) {
        self.id = UUID()
        self.startedAt = Date()
        self.content = content
    }
}
