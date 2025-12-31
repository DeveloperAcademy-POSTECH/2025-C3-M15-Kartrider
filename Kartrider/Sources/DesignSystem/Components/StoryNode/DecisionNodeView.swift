//
//  DecisionNodeView.swift
//  Kartrider
//
//  Created by 박난 on 6/30/25.
//

import SwiftUI

struct DecisionNodeView: View {
    let storyNode: StoryNode
    let isDisabled: Bool
    let selectChoice: (String) -> Void
    var body: some View {
        VStack(spacing: 12) {
            if let choiceA = storyNode.choiceA,
               let choiceB = storyNode.choiceB {
                DecisionBoxView(
                    text: choiceA.text,
                    storyChoiceOption: .a,
                    action: {
                        selectChoice(choiceA.toId)
                    }
                )
                .disabled(isDisabled)

                DecisionBoxView(
                    text: choiceB.text,
                    storyChoiceOption: .b,
                    action: {
                        selectChoice(choiceB.toId)
                    }
                )
                .disabled(isDisabled)
            }
        }
    }
}
