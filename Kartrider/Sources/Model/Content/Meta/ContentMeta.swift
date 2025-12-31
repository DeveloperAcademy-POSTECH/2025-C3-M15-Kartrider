//
//  ContentMeta.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class ContentMeta {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var type: ContentType
    var thumbnailName: String?
    
    @Relationship(deleteRule: .cascade) var hashtags: [Hashtag]
    @Relationship(deleteRule: .cascade) var story: Story?
    @Relationship(deleteRule: .cascade) var tournament: Tournament?
    
    init(title: String, summary: String, type: ContentType, hashtags: [Hashtag], thumbnailName: String? = nil) {
        self.id = UUID()
        self.title = title
        self.summary = summary
        self.type = type
        self.hashtags = hashtags
        self.thumbnailName = thumbnailName
    }
}

