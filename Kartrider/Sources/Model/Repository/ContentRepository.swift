//
//  ContentRepository.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

class ContentRepository: ContentRepositoryProtocol {
    func fetchAllContents(context: ModelContext) throws -> [ContentMeta] {
        let descriptor = FetchDescriptor<ContentMeta>()
        return try context.fetch(descriptor)
    }
    
    func fetchContent(by id: UUID, context: ModelContext) throws -> ContentMeta? {
        let predicate = #Predicate<ContentMeta> { $0.id == id }
        let descriptor = FetchDescriptor<ContentMeta>(predicate: predicate)
        return try context.fetch(descriptor).first
    }
    
    func fetchStory(by id: UUID, context: ModelContext) throws -> Story? {
        let predicate = #Predicate<Story> { $0.id == id }
        let descriptor = FetchDescriptor<Story>(predicate: predicate)
        return try context.fetch(descriptor).first
    }
    
    func fetchTournament(by id: UUID, context: ModelContext) throws -> Tournament? {
        let predicate = #Predicate<Tournament> { $0.id == id }
        let descriptor = FetchDescriptor<Tournament>(predicate: predicate)
        return try context.fetch(descriptor).first
    }
}
