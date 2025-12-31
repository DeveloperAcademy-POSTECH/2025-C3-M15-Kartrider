//
//  WatchStoryViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import Combine
import Foundation

class WatchStoryViewModel: ObservableObject {

    let connectManager = WatchConnectManager.shared

    private var cancellable = Set<AnyCancellable>()

    @Published var currentStage: String = Stage.idle.rawValue

    init() {
        connectManager.$currentStage
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentStage, on: self)
            .store(in: &cancellable)
    }
}
