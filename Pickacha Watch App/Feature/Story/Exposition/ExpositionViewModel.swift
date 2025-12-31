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

        if isTTSPlaying {
            print("[WATCH] 재생")
            connectManager.sendStageExpositionWithResume()
        } else {
            print("[WATCH] 일시정지")
            connectManager.sendStageExpositionWithPause()
        }
    }
}
