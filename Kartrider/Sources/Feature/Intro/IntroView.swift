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

#Preview("스토리") {
    let helper = PreviewHelper()
    let meta = helper.makeStoryMeta()
    helper.makeStory(meta: meta)
    try? helper.context.save()

    return IntroView(content: meta)
        .modelContainer(helper.container)
        .environmentObject(NavigationCoordinator())
}

#Preview("토너먼트") {
    let helper = PreviewHelper()
    let meta = helper.makeTournamentMeta()
    helper.makeTournament(meta: meta)
    try? helper.context.save()

    return IntroView(content: meta)
        .modelContainer(helper.container)
        .environmentObject(NavigationCoordinator())
}
