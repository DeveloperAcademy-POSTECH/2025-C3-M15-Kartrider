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
    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.home,
            onTapRight: { coordinator.push(Route.contentSummary) }
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
        .onAppear {
            viewModel.configure(context: context)
            viewModel.loadContents()
        }
    }
}
