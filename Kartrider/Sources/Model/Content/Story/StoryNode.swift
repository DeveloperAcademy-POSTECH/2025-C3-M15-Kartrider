//
//  StoryNode.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class StoryNode {
    @Attribute(.unique) var id: String
    var text: String
    var type: StoryNodeType
    var nextId: String?
    var endingIndex: Int?
    var title: String?
    
    @Relationship(deleteRule: .cascade) var choiceA: StoryChoice?
    @Relationship(deleteRule: .cascade) var choiceB: StoryChoice?
    @Relationship var story: Story? //
    
    // MARK: 컨벤션을 맞추자!
    init(id: String, text: String, type: StoryNodeType, nextId: String? = nil, endingIndex: Int? = nil, title: String? = nil, story: Story? = nil, choiceA: StoryChoice? = nil, choiceB: StoryChoice? = nil) {
        self.id = id
        self.text = text
        self.type = type
        self.nextId = nextId
        self.endingIndex = endingIndex
        self.title = title
        self.story = story
        self.choiceA = choiceA
        self.choiceB = choiceB
    }
}


