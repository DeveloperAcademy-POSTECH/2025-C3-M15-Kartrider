//
//  HomeView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.home,
            onTapRight: { coordinator.push(Route.contentLibrary) }
        ) {
            Divider()
            
            VStack(spacing: 12) {
                HomeHeaderView()
                    .padding(.bottom, 8)
                    .padding(.vertical, 6)
                
                ContentCarouselView(
                    contents: viewModel.contents,
                    initialIndex: viewModel.selectedIndex
                ) { selected in
                    viewModel.selectContent(selected)
                    coordinator.push(Route.intro(selected))
                }
            }
        }
        .task {
            viewModel.loadContents(context: context)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let schema = Schema([ContentMeta.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = container.mainContext

            let sampleContents = [
                ContentMeta(
                    title: "눈 떠보니 내가 T1 페이커?!",
                    summary: "오늘이 MSI 결승인데, 아이언인 내가 페이커 몸에 들어와버림",
                    type: .story,
                    hashtags: ["페이커", "빙의", "큰일남"],
                    thumbnailName: nil
                ),
                ContentMeta(
                    title: "마법학교 입학 통지서",
                    summary: "갑자기 부엉이가 날아와 입학하래",
                    type: .story,
                    hashtags: ["마법", "학원물"],
                    thumbnailName: nil
                ),
                ContentMeta(
                    title: "아쉬워 벌써 12시",
                    summary: "아쉬워 벌써 12시네",
                    type: .story,
                    hashtags: ["절대 집에 가", "청하", "메아리"],
                    thumbnailName: nil
                )
            ]
            sampleContents.forEach { context.insert($0) }

            let viewModel = HomeViewModel()
            viewModel.contents = sampleContents

            return AnyView (
                HomeView()
                    .modelContainer(container)
                    .environmentObject(NavigationCoordinator())
            )
            
        } catch {
            return AnyView(Text("프리뷰 생성 실패: \(error.localizedDescription)"))
        }
    }
}
