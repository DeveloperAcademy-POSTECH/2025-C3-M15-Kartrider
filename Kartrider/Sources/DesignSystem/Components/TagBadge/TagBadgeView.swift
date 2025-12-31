//
//  TagBadgeView.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import SwiftUI

struct TagBadgeView: View {
    let text: String
    let style: TagBadgeStyle
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.primaryOrange
        case .secondary:
            return Color.hashtagBackground
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return Color.white
        case .secondary:
            return Color.textSecondary
        }
    }
    
    var body: some View {
        Text("#\(text)")
            .font(.caption2.bold())
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(6)
    }
}

#Preview {
    TagBadgeView(text: "현대판타지", style: .primary)
    TagBadgeView(text: "빙의", style: .primary)
    TagBadgeView(text: "성장", style: .secondary)
}
