//  IntroView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct IntroView: View {
    @Environment(\.modelContext) private var context

    @EnvironmentObject private var coordinator: NavigationCoordinator
    @StateObject private var viewModel: IntroViewModel
    @EnvironmentObject private var iosConnectManager: IosConnectManager

    init(content: ContentMeta) {
        _viewModel = StateObject(wrappedValue: IntroViewModel(content: content))
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.intro,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack(spacing: 16) {

                thumbnailSection

                Divider()
                    .frame(width: 360)

                descriptionSection

                actionSection
            }
        }
    }

    private var thumbnailSection: some View {
        ContentCardView(
            content: viewModel.content, showsTags: false, imageHeight: 435,
            aspectRatio: 320.0 / 435.0)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.content.title)
                .font(.title2)
                .bold()
                .foregroundColor(Color.textPrimary)

            Text(viewModel.content.summary.insertLineBreak(every: 32))
                .font(.footnote)
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ForEach(viewModel.content.hashtags, id: \.self) { tag in
                    TagBadgeView(text: tag, style: .secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private var actionSection: some View {
        OrangeButton(title: "이야기 시작하기") {
            print("시작버튼 눌림")

            iosConnectManager.sendStageIdle()

            switch viewModel.content.type {
            case .story:
                if let startNodeId = viewModel.content.story?.startNodeId {
                    coordinator.push(
                        Route.story(viewModel.content.title, startNodeId))
                } else {
                    print("[ERROR] 스토리가 존재하지 않음")
                }
            case .tournament:
                if let id = viewModel.content.tournament?.id {
                    coordinator.push(
                        Route.tournament(viewModel.content.title, id))
                } else {
                    print("[ERROR] 토너먼트가 존재하지 않음")
                }
            }
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    let sample = ContentMeta(
        title: "눈 떠보니 내가 T1 페이커?!",
        summary: "2025 월즈가 코 앞인데 아이언인 내가 어느날 눈 떠보니 페이커 몸에 들어와버렸다.",
        type: .story,
        hashtags: ["빙의", "LOL", "고트"],
        thumbnailName: nil
    )

    return IntroView(content: sample)
        .environmentObject(NavigationCoordinator())
}
