//
//  ContentSummaryView.swift
//  Kartrider
//
//  Created by J on 5/28/25.
//

import SwiftUI

struct ContentSummaryView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = ContentSummaryViewModel()


    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.archive,
            onTapLeft: { coordinator.pop() }
        ) {
            Divider()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.histories) { history in
                        HistoryRowView(
                            history: history,
                            endingTitle: viewModel.endingTitle(for: history),
                            date: viewModel.formattedDate(history)
                        )
                        .onTapGesture {
                            coordinator.push(.contentPlayback(history))
                        }
                        Divider()
                    }
                }
            }
        }
        .onAppear {
            viewModel.configure(context: context)
            viewModel.loadHistories()
        }
    }
}

#Preview {
    ContentSummaryView()
        .environmentObject(NavigationCoordinator())
}
