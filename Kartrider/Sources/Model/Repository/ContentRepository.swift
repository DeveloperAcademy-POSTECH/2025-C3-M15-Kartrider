//
//  ContentRepository.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

class ContentRepository: ContentRepositoryProtocol {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAllContents() throws -> [ContentMeta] {
        try context.fetch(FetchDescriptor<ContentMeta>())
    }
    
    func fetchContent(by id: UUID) throws -> ContentMeta? {
        let predicate = #Predicate<ContentMeta> { $0.id == id }
        return try context.fetch(FetchDescriptor<ContentMeta>(predicate: predicate)).first
    }
    
    func fetchStory(by id: UUID) throws -> Story? {
        let predicate = #Predicate<Story> { $0.id == id }
        return try context.fetch(FetchDescriptor<Story>(predicate: predicate)).first
    }
    
    func fetchTournament(by id: UUID) throws -> Tournament? {
        let predicate = #Predicate<Tournament> { $0.id == id }
        return try context.fetch(FetchDescriptor<Tournament>(predicate: predicate)).first
    }
}
