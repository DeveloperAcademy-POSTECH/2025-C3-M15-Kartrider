//
//  IosConnectManager.swift
//  Kartrider
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class IosConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    static let shared = IosConnectManager()

    var session: WCSession

    @Published var message: [String: Any] = [:]
    @Published var isTTSPlaying: Bool = true
    @Published var decisionIndex: Int = 0
    @Published var decisionCount: Int = 0
    @Published var selectedChoice: String = ""
    @Published var selectedOption: StoryChoiceOption? = nil
    @Published var isTimeout: Bool? = false
    @Published var isFirstRequest: Bool = true

    private enum messageKey: String {
        case isTTSPlaying
        case decisionIndex
        case decisionCount
        case selectedChoice
        case selectedOption
        case isTimeout
        case isFirstRequest
    }

    private init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        DispatchQueue.main.async {
            if let isTTSPlaying = message[messageKey.isTTSPlaying.rawValue]
                as? Bool
            {
                self.isTTSPlaying = isTTSPlaying
            }

            if let decisionIndex = message[messageKey.decisionIndex.rawValue]
                as? Int
            {
                self.decisionIndex = decisionIndex
            }

            if let decisionCount = message[messageKey.decisionCount.rawValue]
                as? Int
            {
                self.decisionCount = decisionCount
            }

            if let isTimeout = message[messageKey.isTimeout.rawValue] as? Bool {
                self.isTimeout = isTimeout
            }

            if let isFirstRequest = message[messageKey.isFirstRequest.rawValue]
                as? Bool
            {
                self.isFirstRequest = isFirstRequest
            }

            if let selectedChoiceRaw = message[
                messageKey.selectedChoice.rawValue] as? String,
                let selectedChoice = StoryChoiceOption(
                    rawValue: selectedChoiceRaw)
            {
                //                self.selectedOption = nil
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.selectedOption = selectedChoice
                //                }
            }

        }
    }

    func sendStageIdle() {
        let message: [String: Any] = [
            "currentStage": "idle",
            "hasStartedContent": true,
        ]

        let session = WCSession.default
        // TODO: Logger같은 것들?
        print("[DEBUG] idle message 보내기: \(message)")

        if session.isReachable {
            print("[DEBUG] 워치로 idle 메시지 전송")
            session.sendMessage(message, replyHandler: nil)
        } else {
            print("[INFO] 세션 도달 불가. 1초 뒤 재시도.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.sendStageIdle()
            }
        }
    }

    func sendStageExpositionWithPause() {
        let message: [String: Any] = [
            "currentStage": "exposition",
            "isTTSPlaying": false,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageExpositionWithResume() {
        let message: [String: Any] = [
            "currentStage": "exposition",
            "isTTSPlaying": true,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageDecisionWithFirstTTS(_ decisionIndex: Int) {
        let message: [String: Any] = [
            "currentStage": "decision",
            "isTimerRunning": false,
            "decisionIndex": decisionIndex,
            "isFirstRequest": true,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageDecisionWithFirstTimer(_ decisionIndex: Int) {
        let message: [String: Any] = [
            "currentStage": "decision",
            "isTimerRunning": true,
            "decisionIndex": decisionIndex,
            "isFirstRequest": true,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageDecisionWithSecTTS(_ decisionIndex: Int) {
        let message: [String: Any] = [
            "currentStage": "decision",
            "isTimerRunning": false,
            "decisionIndex": decisionIndex,
            "isFirstRequest": false,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageDecisionWithSecTimer(_ decisionIndex: Int) {
        let message: [String: Any] = [
            "currentStage": "decision",
            "isTimerRunning": true,
            "decisionIndex": decisionIndex,
            "isFirstRequest": false,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendChoiceInterrupt() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(
                [
                    "currentStage": "decision",
                    "isInterrupted": true,
                ], replyHandler: nil)
        }
    }

    func sendStageEndingTTS() {
        let message: [String: Any] = [
            "currentStage": "ending",
            "isTimerRunning": false,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageEndingTimer() {
        let message: [String: Any] = [
            "currentStage": "ending",
            "isTimerRunning": true,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {

    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }
}
