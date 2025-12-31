//
//  Story.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class Story {
    @Attribute(.unique) var id: UUID
    var startNodeId: String
    
    @Relationship(deleteRule: .cascade, inverse: \ContentMeta.story) var meta: ContentMeta
    @Relationship(deleteRule: .cascade) var nodes: [StoryNode] = []
    @Relationship(deleteRule: .cascade) var endingConditions: [EndingCondition] = []
    
    init(startNodeId: String, meta: ContentMeta) {
        self.id = UUID()
        self.startNodeId = startNodeId
        self.meta = meta
    }
}
