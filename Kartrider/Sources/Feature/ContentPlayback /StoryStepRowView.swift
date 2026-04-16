//
//  StoryStepRowView.swift
//  Kartrider
//
//  Created by J on 4/16/26.
//

import Foundation
import SwiftUI

struct StoryStepRowView: View {
    let step: StoryStep

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 노드 텍스트
            if !step.nodeText.isEmpty {
                Text(step.nodeText)
                    .font(.body)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }

            // 선택지 (decision 노드만)
            if let selectedText = step.selectedText,
               let selectedChoice = step.selectedChoice {
                HStack(spacing: 12) {
                    Text(selectedChoice == .a ? "A" : "B")
                        .font(.body.bold())
                        .foregroundStyle(Color.primaryOrange)
                    Text(selectedText)
                        .font(.body.bold())
                        .foregroundStyle(Color.primaryOrange)
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryOrange, lineWidth: 1.5)
                )
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 8)
    }
}
