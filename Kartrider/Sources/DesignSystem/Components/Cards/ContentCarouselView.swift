//
//  ContentCarouselView.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import SwiftUI

struct ContentCarouselView: View {
    let contents: [ContentMeta]
    let initialIndex: Int
    var onTap: (ContentMeta) -> Void
    
    @GestureState private var translation: CGFloat = 0
    @State private var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.7
            let spacing: CGFloat = 16
            let totalSpacing = spacing + cardWidth
            let horizontalPadding = (geometry.size.width - cardWidth) / 2
            
            HStack(spacing: spacing) {
                ForEach(contents.indices, id: \.self) { index in
                    ContentCardView(content: contents[index])
                        .frame(width: cardWidth)
                        .scaleEffect(currentIndex == index ? 1.0 : 0.9)
                        .animation(.easeInOut(duration: 0.25), value: currentIndex)
                        .onTapGesture {
                            onTap(contents[index])
                        }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .offset(x: -CGFloat(currentIndex) * totalSpacing + translation)
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 4 // 4pt 이상이면 이동
                        let dragDistance = value.translation.width

                        if dragDistance > threshold {
                            currentIndex = max(0, currentIndex - 1) // 오른쪽으로 드래그 → 이전 카드
                        } else if dragDistance < -threshold {
                            currentIndex = min(contents.count - 1, currentIndex + 1) // 왼쪽으로 드래그 → 다음 카드
                        }
                    }
            )
        }
        .frame(height: 500)
        .onAppear {
            currentIndex = initialIndex
        }
        
        // Page Indicator
        PageIndicatorView(
            totalCount: contents.count,
            currentIndex: currentIndex
        )
    }
}

#Preview {
    let dummyContents: [ContentMeta] = [
        ContentMeta(
            title: "눈 떠보니 내가 T1 페이커?!",
            summary: "오늘이 MSI 결승인데, 아이언인 내가 페이커 몸에 들어와버림",
            type: .story,
            hashtags: [
                Hashtag(value: "페이커"),
                Hashtag(value: "빙의"),
                Hashtag(value: "큰일남")
            ],
            thumbnailName: nil
        ),
        ContentMeta(
            title: "마법학교 입학 통지서",
            summary: "갑자기 부엉이가 날아와 입학하래",
            type: .story,
            hashtags: [
                Hashtag(value: "마법"),
                Hashtag(value: "학원물"),
            ],
            thumbnailName: nil
        )
    ]
    
    return ContentCarouselView(contents: dummyContents, initialIndex: 0) { selected in
        print("선택된 콘텐츠: \(selected.title)")
    }
}
