//
//  ContentRepositoryProtocol.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

protocol ContentRepositoryProtocol {
    func fetchAllContents(context: ModelContext) throws -> [ContentMeta]
    func fetchContent(by id: UUID, context: ModelContext) throws -> ContentMeta?
//    func fetchStory(by title: String, context: ModelContext) throws -> Story?
    func fetchStory(by id: UUID, context: ModelContext) throws -> Story?
    func fetchTournament(by id: UUID, context: ModelContext) throws -> Tournament?
}
