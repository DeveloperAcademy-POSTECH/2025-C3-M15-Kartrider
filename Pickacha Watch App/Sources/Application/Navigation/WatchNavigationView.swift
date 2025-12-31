//
//  WatchNavigationView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchNavigationView: View {

    @StateObject private var coordinator = WatchNavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            WatchStartView()
                .navigationDestination(for: WatchRoute.self) {
                    route in
                    switch route {
                    case .start:
                        WatchStartView()
                    case .story:
                        WatchStoryView()
                    case .outro:
                        WatchOutroView()
                    }
                }
        }
        .environmentObject(coordinator)
    }
}
