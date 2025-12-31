//
//  TournamentMatchView.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import SwiftUI

struct TournamentMatchView: View {
    let roundDescription: String
    let a: String
    let b: String
    let onSelectA: () -> Void
    let onSelectB: () -> Void
    var buttonDisabled: Bool = false
    var selectedOption: StoryChoiceOption?
    
    var body: some View {
        VStack(spacing: 18) {
            DescriptionBoxView(text: roundDescription)
            
            VStack(spacing: 12) {
                DecisionBoxView(
                    text: a,
                    storyChoiceOption: StoryChoiceOption.a,
                    isSelected: selectedOption == .a,
                    action: onSelectA
                )
                .disabled(buttonDisabled)
                
                DecisionBoxView(
                    text: b,
                    storyChoiceOption: StoryChoiceOption.b,
                    isSelected: selectedOption == .b,
                    action: onSelectB
                )
                .disabled(buttonDisabled)
            }
            
            Spacer()
        }
    }
}

#Preview {
    TournamentMatchView(roundDescription: "결승\n1번째 경기 중 1번째", a: "젤리", b: "펩시 제로 슈거 라임향", onSelectA: {}, onSelectB: {})
}
