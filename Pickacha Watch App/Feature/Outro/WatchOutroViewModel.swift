//
//  WatchOutroViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import Combine
import Foundation
import WatchKit

class WatchOutroViewModel: ObservableObject {

    // MARK: - Properties

    let connectManager = WatchConnectManager.shared

    private var cancellable = Set<AnyCancellable>()
    private var timer: Timer?

    // MARK: - Published

    @Published var time = 10
    @Published var progress: CGFloat = 1.0
    @Published var isTimerRunning = false

    // MARK: - Init

    init() {
        connectManager.$isTimerRunning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                isTimerRunning = newValue
                if newValue { startTimer() }
            }
            .store(in: &cancellable)
    }

    // MARK: - Timer

    func startTimer() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if time > 0 {
                time -= 1
                progress = CGFloat(time) / 10.0
                WKInterfaceDevice.current().play(.start)
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
}
