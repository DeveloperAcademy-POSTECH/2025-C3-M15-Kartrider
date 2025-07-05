//
//  WatchStoryView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchStoryView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    @StateObject private var watchStoryViewModel = WatchStoryViewModel()

    var body: some View {
        VStack {
            switch watchStoryViewModel.currentStage {
            case Stage.exposition.rawValue:
                ExpositionView()
            case Stage.decision.rawValue:
                DecisionView()
            case Stage.ending.rawValue:
                Color.clear.onAppear {
                    coordinator.push(.outro)
                }
            default: Text("Loading...")
            }
        }.id(watchStoryViewModel.currentStage)
    }
}
