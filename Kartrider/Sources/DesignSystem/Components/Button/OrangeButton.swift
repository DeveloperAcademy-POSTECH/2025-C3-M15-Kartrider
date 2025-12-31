//
//  OrangeButton.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import SwiftUI

struct OrangeButton: View {
    var title: String
    var icon: Image? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon = icon {
                    icon
                        .font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(.callout.bold())
            }
            .foregroundColor(Color.white)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(Color.primaryOrange)
            .cornerRadius(8)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    OrangeButton(title: "이야기 시작하기", action: {})
    OrangeButton(title: "다음 이야기",icon: Image(systemName: "play.fill"), action: {})
    OrangeButton(title: "전체 이야기 보기", action: {})
}
