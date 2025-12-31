//
//  IntroThumbnailView.swift
//  Kartrider
//
//  Created by J on 6/27/25.
//

import SwiftUI

struct IntroThumbnailView: View {
    let content: ContentMeta
    
    var body: some View {
        ContentCardView(
            content: content,
            showsTags: false,
            imageHeight: 435,
            aspectRatio: 320.0 / 435.0)
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

    IntroThumbnailView(content: sample)
}
