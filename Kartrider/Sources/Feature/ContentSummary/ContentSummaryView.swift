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
    let helper = PreviewHelper()

    let storyMeta = helper.makeStoryMeta()
    helper.makeStory(meta: storyMeta)
    helper.makeStoryHistory(meta: storyMeta)

    let tournamentMeta = helper.makeTournamentMeta()
    let tournament = helper.makeTournament(meta: tournamentMeta)
    if let winner = tournament.candidates.first {
        helper.makeTournamentHistory(meta: tournamentMeta, winner: winner)
    }

    try? helper.context.save()

    return ContentSummaryView()
        .modelContainer(helper.container)
        .environmentObject(NavigationCoordinator())
}
