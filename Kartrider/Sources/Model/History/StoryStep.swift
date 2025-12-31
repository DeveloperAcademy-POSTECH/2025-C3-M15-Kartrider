//
//  StoryStep.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation

import Foundation
import SwiftData

@Model
class StoryStep {
    var nodeId: String // 방문한 노드 ID
    
    var type: StoryNodeType
    var nodeText: String
    var selectedChoice: StoryChoiceOption?
    var selectedText: String?
    var timestamp: Date
    
    @Relationship var history: PlayHistory
    @Relationship var node: StoryNode?
    
    init(nodeId: String, type: StoryNodeType, nodeText: String, selectedChoice: StoryChoiceOption? = nil, selectedText: String? = nil, timestamp: Date, history: PlayHistory, node: StoryNode? = nil) {
        self.nodeId = nodeId
        self.type = type
        self.nodeText = nodeText
        self.selectedChoice = selectedChoice
        self.selectedText = selectedText
        self.timestamp = timestamp
        self.history = history
        self.node = node
    }
}
