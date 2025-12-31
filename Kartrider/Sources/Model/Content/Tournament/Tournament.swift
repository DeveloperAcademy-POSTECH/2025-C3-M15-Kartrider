//
//  Tournament.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class Tournament {
    @Attribute(.unique) var id: UUID
    
    @Relationship(inverse: \ContentMeta.tournament) var meta: ContentMeta
    @Relationship(deleteRule: .cascade) var candidates: [Candidate] = []
    
    init(meta: ContentMeta) {
        self.id = UUID()
        self.meta = meta
    }
}
