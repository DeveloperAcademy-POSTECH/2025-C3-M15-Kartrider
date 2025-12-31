//
//  JSONParser.swift
//  Kartrider
//
//  Created by J on 6/28/25.
//

import Foundation
import SwiftData

protocol JSONInsertable: Decodable {
    var meta: MetaData { get }
    func insert(into context: ModelContext, meta: ContentMeta) throws
}

struct JSONParser<T: JSONInsertable> {
    let fileName: String
    private let decoder: JSONDecoder = JSONDecoder()
    
    func loadJSON() throws -> Data {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw JSONParseError.fileNotFound(fileName)
        }
        return try Data(contentsOf: url)
    }
    
    func decode() throws -> [T] {
        let data = try loadJSON()
        return try decoder.decode([T].self, from: data)
    }

    func insertData(into context: ModelContext) throws {
        let decodedList = try decode()
        
        for content in decodedList {
            
            let hashtagModels = content.meta.hashtags.map { Hashtag(value: $0) }
            
            let meta = ContentMeta(
                title: content.meta.title,
                summary: content.meta.summary,
                type: ContentType(rawValue: content.meta.type) ?? .story,
                hashtags: hashtagModels,
                thumbnailName: content.meta.thumbnailName
            )
            context.insert(meta)
            try content.insert(into: context, meta: meta)
        }
        
        try context.save()
    }
}

extension StoryJSON: JSONInsertable {
    func insert(into context: ModelContext, meta: ContentMeta) throws {
        let storyEntity = Story(startNodeId: story.startNodeId, meta: meta)
        context.insert(storyEntity)
        
        for node in story.nodes {
            let nodeEntity = StoryNode(
                id: node.id,
                text: node.text,
                type: node.type,
                nextId: node.nextId,
                endingIndex: node.endingIndex,
                title: node.title,
                story: storyEntity
            )
            context.insert(nodeEntity)
            
            if let choiceA = node.choiceA {
                let a = StoryChoice(text: choiceA.text, toId: choiceA.toId)
                context.insert(a)
                nodeEntity.choiceA = a
            }
            
            if let choiceB = node.choiceB {
                let b = StoryChoice(text: choiceB.text, toId: choiceB.toId)
                context.insert(b)
                nodeEntity.choiceB = b
            }
        }
        
        for ending in story.endingConditions {
            let endingCondition = EndingCondition(
                pathString: ending.path.map { $0.rawValue }.joined(separator: "-"),
                toId: ending.toId
            )
            endingCondition.story = storyEntity
            context.insert(endingCondition)
        }
    }
}

extension TournamentJSON: JSONInsertable {
    func insert(into context: ModelContext, meta: ContentMeta) throws {
        let tournamentEntity = Tournament(meta: meta)
        context.insert(tournamentEntity)
        
        for candidate in candidates {
            let candidateEntity = Candidate(name: candidate.name, tournament: tournamentEntity)
            tournamentEntity.candidates.append(candidateEntity)
            context.insert(candidateEntity)
        }
    }
}



