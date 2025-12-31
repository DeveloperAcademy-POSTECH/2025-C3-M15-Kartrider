//
//  Candidate.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class Candidate {
    @Attribute(.unique) var id: UUID
    var name: String
    
    @Relationship var tournament: Tournament
    
    init( name: String, tournament: Tournament) {
        self.id = UUID()
        self.name = name
        self.tournament = tournament
    }
}

