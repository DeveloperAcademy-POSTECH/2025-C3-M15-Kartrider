//
//  TextBoxView.swift
//  Kartrider
//
//  Created by 박난 on 6/1/25.
//

import SwiftUI

struct DescriptionBoxView: View {
    let text: String
    let karaokeMode: Bool = false
    let currentIndex: Int = -1

    var body: some View {
        if karaokeMode {
            // 나중에 KaraokeTextView 추가
        } else {
            Text(text)
                .font(.system(size: 24, weight: .bold))
                .lineSpacing(6)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cardBackground)
                )
                .padding(.horizontal, 16)
        }
    }
}

#Preview {
    DescriptionBoxView(text: "104기 훈련병단 졸업식 날. 당신은 조사병단을 선택했다. 에렌, 미카사, 아르민이 당신을 바라보며 고개를 끄덕인다. 갑작스런 출동 명령이 내려진다.")
    DescriptionBoxView(text: "첫번째 문장입니다.")
}
