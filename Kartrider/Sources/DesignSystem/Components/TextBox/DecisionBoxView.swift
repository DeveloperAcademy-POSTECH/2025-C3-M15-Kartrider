//
//  DecisionBoxView.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//

import SwiftUI

struct DecisionBoxView: View {
    let text: String
    let storyChoiceOption: StoryChoiceOption
    var isSelected: Bool = false // 선택 여부
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Group {
                    Text(storyChoiceOption.rawValue)
                        .font(.title)
                    Text(text)
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                }
                .bold()
                .foregroundColor(isSelected ? Color.white : Color.primaryOrange)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.primaryOrange : Color.backgroundOrangeLight)
                    .stroke(Color.primaryOrange, lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    DecisionBoxView(text: "어쩌구저쩌구어쩌구저쩌구어쩌구", storyChoiceOption: StoryChoiceOption.a, action: {})
    DecisionBoxView(text: "어쩌구저쩌구어쩌구저쩌구어쩌구", storyChoiceOption: StoryChoiceOption.b, isSelected: true, action: {})
}
