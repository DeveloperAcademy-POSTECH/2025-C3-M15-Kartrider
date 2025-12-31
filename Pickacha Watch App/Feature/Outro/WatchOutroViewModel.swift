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

    let connectManager = WatchConnectManager.shared

    private var cancellable = Set<AnyCancellable>()

    @Published var time = 10
    @Published var progress: CGFloat = 1.0
    @Published var isTimerRunning = false
    private var timer: Timer?

    init() {
        connectManager.$isTimerRunning
            .receive(on: DispatchQueue.main)
            .sink { newValue in
                if newValue {
                    self.startTimer()
                }
                self.isTimerRunning = newValue
            }
            .store(in: &cancellable)
    }

    func startTimer() {
        guard !isTimerRunning else { return }

        isTimerRunning = true
        connectManager.isTimerRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.time > 0 {
                self.time -= 1
                self.progress = CGFloat(self.time) / 10.0
                WKInterfaceDevice.current().play(.start)
            } else {
                self.timer?.invalidate()
                print("[ENDING] Time Out")
            }
        }
    }
}
