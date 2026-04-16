//
//  StoryStepData.swift
//  Kartrider
//
//  Created by J on 4/16/26.
//

import Foundation

struct StoryStepData {
    let nodeId: String
    let type: StoryNodeType
    let nodeText: String
    let selectedChoice: StoryChoiceOption?
    let selectedText: String?
    let timestamp: Date
}
