//
//  TournamentDTO.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation

struct TournamentJSON: Decodable {
    let meta: MetaData
    let candidates: [CandidateData]
}

struct CandidateData: Decodable {
    let name: String
}

