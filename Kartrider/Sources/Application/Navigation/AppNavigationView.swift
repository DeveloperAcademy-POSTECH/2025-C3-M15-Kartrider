//
//  AppNavigationView.swift
//  Kartrider
//
//  Created by J on 5/28/25.
//

import SwiftUI

struct AppNavigationView: View {

    @StateObject var coordinator = NavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .home:
                        HomeView()
                    case .intro(let content):
                        IntroView(content: content)
                    case .story(let content):
                        StoryView(content: content)
                    case .tournament(let content):
                        TournamentView(content: content)
                    case .contentSummary:
                        ContentSummaryView()
                    case .contentPlayback(let history):
                        ContentPlaybackView(history: history)
                    }
                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    AppNavigationView()
}
