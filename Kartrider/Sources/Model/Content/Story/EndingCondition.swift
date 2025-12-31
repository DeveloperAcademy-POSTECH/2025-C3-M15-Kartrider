//
//  EndingCondition.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class EndingCondition {
    var pathString: String // 저장된 형태: 'A-B-A'
    var toId: String
    
    var path: [StoryChoiceOption] {
        pathString
            .split(separator: "-")
            .compactMap { StoryChoiceOption(rawValue: String($0)) }
    }
    
    @Relationship var story: Story?
    
    init(pathString: String, toId: String) {
        self.pathString = pathString
        self.toId = toId
    }
}

