//
//  WatchStoryViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import Combine
import Foundation

class WatchStoryViewModel: ObservableObject {

    // MARK: - Properties

    let connectManager = WatchConnectManager.shared
    private var cancellable = Set<AnyCancellable>()

    // MARK: - Published

    @Published var currentStage: String = Stage.idle.rawValue

    // MARK: - Init

    init() {
        connectManager.$currentStage
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentStage, on: self)
            .store(in: &cancellable)
    }
}
