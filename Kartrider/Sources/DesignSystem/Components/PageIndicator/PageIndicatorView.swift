//
//  PageIndicatorView.swift
//  Kartrider
//
//  Created by J on 6/1/25.
//

import SwiftUI

struct PageIndicatorView: View {
    let totalCount: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<totalCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.primaryOrange : Color(uiColor: .indicator))
                    .frame(width: index == currentIndex ? 18 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.divider, lineWidth: 1)
        )
    }
}

#Preview {
    PageIndicatorView(totalCount: 5, currentIndex: 1)
}
