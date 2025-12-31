//
//  StoryNodeContentView.swift
//  Kartrider
//
//  Created by 박난 on 6/30/25.
//

import SwiftUI

struct StoryNodeContentView: View {
    let storyNode: StoryNode
    let isDisabled: Bool
    let selectChoice: (String) -> Void
    let title: String
    
    var body: some View {
        switch storyNode.type {
        case .exposition:
            EmptyView()
        case .decision:
            DecisionNodeView(
                storyNode: storyNode,
                isDisabled: isDisabled,
                selectChoice: selectChoice
            )
        case .ending:
            EndingNodeView(title: title)
        }
    }
}
