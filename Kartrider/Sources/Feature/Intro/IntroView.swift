//  IntroView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct IntroView: View {
    @Environment(\.modelContext) private var context

    @EnvironmentObject private var coordinator: NavigationCoordinator
    @StateObject private var introViewModel: IntroViewModel

    init(content: ContentMeta) {
        _introViewModel = StateObject(
            wrappedValue: IntroViewModel(content: content))
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.intro,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack(spacing: 16) {

                IntroThumbnailView(content: introViewModel.content)

                Divider()
                    .frame(width: 360)

                IntroDescriptionView(content: introViewModel.content)

                OrangeButton(title: "이야기 시작하기") {
                    if let route = introViewModel.startContentRoute() {
                        coordinator.push(route)
                    }
                }
                .padding(.vertical, 20)
            }
        }
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

    return IntroView(content: sample)
        .environmentObject(NavigationCoordinator())
}
