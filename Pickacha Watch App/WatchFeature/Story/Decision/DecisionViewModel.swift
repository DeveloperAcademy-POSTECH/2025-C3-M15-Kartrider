//
//  DecisionViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/3/25.
//

import Combine
import CoreMotion
import Foundation
import WatchKit

class DecisionViewModel: ObservableObject {

    let connectManager = WatchConnectManager.shared

    private var cancellable = Set<AnyCancellable>()

    @Published var isTimerRunning = false
    @Published var isInterrupted = false
    @Published var isFirstRequest = true
    @Published var decisionIndex = 0

    @Published var time = 10
    @Published var progress: CGFloat = 1.0
    @Published var isTimeOut = false
    @Published var choice: String?

    private var timer: Timer?
    private var motionManager = CMMotionManager()
    private var isSetMiddle = false
    private var middle: Double = 0.0

    init() {
        connectManager.$isTimerRunning
            .receive(on: DispatchQueue.main)
            .sink {
                newValue in
                if self.connectManager.currentStage == Stage.decision.rawValue {
                    if newValue {
                        self.resetState()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.isTimerRunning = true  // 타이머 화면이 2번 그려지는데(0.0001초 동안 타이머->선택지재생->타이머) 약간의 로직 수정이 필요합니다
                            self.makeChoice()
                        }
                    } else {
                        self.isTimerRunning = false
                    }
                    print("[DECISION] isTimerRunning: \(self.isTimerRunning)")
                } else {

                    self.isTimerRunning = false
                }
            }
            .store(in: &cancellable)

        connectManager.$isInterrupted
            .receive(on: DispatchQueue.main)
            .sink { newValue in
                if newValue == true {
                    self.interruptByPhone()
                }
            }
            .store(in: &cancellable)

        connectManager.$isFirstRequest
            .receive(on: DispatchQueue.main)
            .sink { newValue in
                self.isFirstRequest = newValue
                self.resetState()
            }
            .store(in: &cancellable)

        connectManager.$decisionIndex
            .receive(on: DispatchQueue.main)
            .sink { newValue in
                self.decisionIndex = newValue
                self.resetState()
            }
            .store(in: &cancellable)
    }

    func resetState() {
        isTimeOut = false
        choice = nil
        time = 10
        progress = 1.0
        motionManager.stopDeviceMotionUpdates()
        middle = 0.0
        isSetMiddle = false
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    func timeOut() {
        stopTimer()
        isTimeOut = true
        time = 0
        progress = 0.0
        motionManager.stopDeviceMotionUpdates()
    }

    func choiceDone() {
        self.timer?.invalidate()
        self.motionManager.stopDeviceMotionUpdates()
    }

    func startTimer() {
        stopTimer()

        DispatchQueue.main.async {
            self.isTimerRunning = true
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            print("[TIMER] \(self.time)")
            if self.time > 0 {
                self.time -= 1
                self.progress = CGFloat(self.time) / 10.0
                WKInterfaceDevice.current().play(.start)
            } else {
                if !self.isTimeOut {
                    self.timeOut()
                    print("[DECISION] Time Out")

                    self.connectManager.sendTimeoutToIos(
                        self.decisionIndex, isFirstRequest: self.isFirstRequest)
                }
            }
        }
    }

    func makeChoice() {

        guard motionManager.isDeviceMotionAvailable else {
            print("unavailable")
            return
        }

        if motionManager.isDeviceMotionActive { return }

        motionManager.deviceMotionUpdateInterval = 0.1
        isSetMiddle = false
        middle = 0.0

        motionManager.startDeviceMotionUpdates(to: .main) { data, error in
            guard let data = data, error == nil else {
                print(
                    "Motion data error: \(error?.localizedDescription ?? "Unknown")"
                )
                return
            }

            guard self.choice == nil else { return }

            guard self.isTimerRunning else { return }

            let roll = data.attitude.roll

            if !self.isSetMiddle {
                self.middle = roll
                self.isSetMiddle = true
                print("[MOTION] middle set: \(roll)")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startTimer()
                }
                return
            }

            let value = roll - self.middle

            self.evalLOrR(value)
        }
    }

    func evalLOrR(_ value: Double) {
        if value > 0.6 {
            self.choice = "B"
            choiceDone()
            print("[CHOICE] B")
            if self.isFirstRequest {
                self.connectManager.sendFirstChoiceToIos(
                    self.decisionIndex, "B")
            } else {
                self.connectManager.sendSecChoiceToIos(
                    self.decisionIndex, "B")
            }
        } else if value < -0.6 {
            self.choice = "A"
            choiceDone()
            print("[CHOICE] A")
            if self.isFirstRequest {
                self.connectManager.sendFirstChoiceToIos(
                    self.decisionIndex, "A")
            } else {
                self.connectManager.sendSecChoiceToIos(
                    self.decisionIndex, "A")
            }
        }
    }

    func interruptByPhone() {
        print("[WATCH] ios에서 보낸 interrupt")
        stopTimer()
        motionManager.stopDeviceMotionUpdates()
    }
}
