//
//  ContentRepositoryProtocol.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

protocol ContentRepositoryProtocol {
    func fetchAllContents() throws -> [ContentMeta]
    func fetchContent(by id: UUID) throws -> ContentMeta?
    func fetchStory(by id: UUID) throws -> Story?
    func fetchTournament(by id: UUID) throws -> Tournament?
}
