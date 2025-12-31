//
//  NavigationButtonConfig.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation
import SwiftUI

struct NavigationButtonConfig: Equatable {
    let type: NavigationButtonType
    let color: Color

    static func back(color: Color) -> NavigationButtonConfig {
        .init(type: .back, color: color)
    }

    static func book(color: Color) -> NavigationButtonConfig {
        .init(type: .book, color: color)
    }
}
