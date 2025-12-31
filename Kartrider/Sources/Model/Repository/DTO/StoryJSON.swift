//
//  StoryDTO.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation

struct StoryJSON: Decodable {
    let meta: MetaData
    let story: StoryData
}

struct StoryData: Decodable {
    let startNodeId: String
    let nodes: [NodeData]
    let endingConditions: [EndingConditionData]
}

struct NodeData: Decodable {
    let id: String
    let text: String
    let type: StoryNodeType
    let nextId: String?
    let endingIndex: Int?
    let title: String?
    let choiceA: ChoiceData?
    let choiceB: ChoiceData?
}

struct ChoiceData: Decodable {
    let text: String
    let toId: String
}

struct EndingConditionData: Decodable {
    let path: [StoryChoiceOption]
    let toId: String
}
