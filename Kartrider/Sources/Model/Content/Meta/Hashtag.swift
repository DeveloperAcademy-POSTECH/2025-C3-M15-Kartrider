//
//  Hashtag.swift
//  Kartrider
//
//  Created by J on 7/14/25.
//

import Foundation
import SwiftData

@Model
class Hashtag {
    var value: String
    
    init(value: String) {
        self.value = value
    }
}
