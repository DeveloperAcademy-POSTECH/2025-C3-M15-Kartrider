//
//  IntroDescriptionView.swift
//  Kartrider
//
//  Created by J on 6/27/25.
//

import SwiftUI

struct IntroDescriptionView: View {
    let content: ContentMeta
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(content.title)
                .font(.title2)
                .bold()
                .foregroundColor(Color.textPrimary)

            Text(content.summary.insertLineBreak(every: 32))
                .font(.footnote)
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ForEach(content.hashtags, id: \.self) { tag in
                    TagBadgeView(text: tag.value, style: .secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#Preview {
    
    let sample = ContentMeta(
        title: "눈 떠보니 내가 T1 페이커?!",
        summary: "2025 월즈가 코 앞인데 아이언인 내가 어느날 눈 떠보니 페이커 몸에 들어와버렸다.",
        type: .story,
        hashtags: [
            Hashtag(value: "빙의"),
            Hashtag(value: "LOL"),
            Hashtag(value: "고트")
        ],
        thumbnailName: nil
    )
    
    IntroDescriptionView(content: sample)
}
