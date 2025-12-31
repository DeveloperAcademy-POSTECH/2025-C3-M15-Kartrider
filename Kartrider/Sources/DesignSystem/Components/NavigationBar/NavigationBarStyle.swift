//
//  NavigationBarStyle.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation
import SwiftUI

enum NavigationBarStyle: Equatable {
    case home
    case intro
    case play(title: String)
    case archive
    case historyDetail
    case timeline(title: String)

    var leftButton: NavigationButtonConfig? {
        switch self {
        case .home:
            return nil
        case .historyDetail:
            return .back(color: .white)
        default:
            return .back(color: .black)
        }
    }

    var rightButton: NavigationButtonConfig? {
        switch self {
        case .home:
            return nil
//            return .book(color: .black)
        default:
            return nil
        }
    }

    var centerTitleText: String? {
        switch self {
        case .play(let title), .timeline(let title):
            return title
        case .archive:
            return "책꽂이"
        default:
            return nil
        }
    }
    
    @ViewBuilder
    var leftLabel: some View {
        switch self {
        case .home:
            Image("logo")
                .resizable()
                .frame(width: 72, height: 39)
        case .archive:
            HStack(spacing: 4) {
                Image(systemName: NavigationButtonType.back.iconName)
                    .foregroundColor(.black)
                Text("home")
                    .foregroundColor(.gray)
                    .font(.body)
            }
        default:
            if let left = leftButton {
                Image(systemName: left.type.iconName)
                    .foregroundColor(left.color)
            } else {
                Spacer().frame(width: 44)
            }
        }
    }
}
