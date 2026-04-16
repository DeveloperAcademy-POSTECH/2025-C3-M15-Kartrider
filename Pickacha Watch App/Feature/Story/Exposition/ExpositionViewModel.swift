//
//  ExpositionViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/3/25.
//

import Combine
import Foundation

class ExpositionViewModel: ObservableObject {

    let connectManager = WatchConnectManager.shared

    private var cancellable = Set<AnyCancellable>()

    @Published var isTTSPlaying = true

    init() {
        connectManager.$isTTSPlaying
            .receive(on: DispatchQueue.main)
            .assign(to: \.isTTSPlaying, on: self)
            .store(in: &cancellable)
    }

    func toggleStateWatch() {
        isTTSPlaying.toggle()
        connectManager.isTTSPlaying = isTTSPlaying

        connectManager.sendStageExposition(isTTSPlaying: isTTSPlaying)
    }
}
