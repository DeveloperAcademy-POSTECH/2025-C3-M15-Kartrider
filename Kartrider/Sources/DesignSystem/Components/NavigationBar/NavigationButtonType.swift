//
//  NavigationButtonType.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation

enum NavigationButtonType {
    case back
    case book

    var iconName: String {
        switch self {
        case .back: return "chevron.left"
        case .book: return "book"
        }
    }
}
