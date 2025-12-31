//
//  CommonMetaDTO.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation

struct MetaData: Decodable {
    let title: String
    let summary: String
    let type: String
    let hashtags: [String]
    let thumbnailName: String
}

