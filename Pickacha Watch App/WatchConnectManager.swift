//
//  WatchConnectManager.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class WatchConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    static let shared = WatchConnectManager()

    var session: WCSession

    private init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        } else {
            Log.error("WCSession not supported")
        }
    }

    @Published var message: [String: Any] = [:]
    @Published var currentStage: String = ""
    @Published var hasStartedContent: Bool = false
    @Published var isTimerRunning: Bool = false
    @Published var isTTSPlaying: Bool = true
    @Published var decisionIndex: Int = 0
    @Published var isFirstRequest: Bool = false
    @Published var isInterrupted: Bool = false

    private enum messageKey: String {
        case currentStage
        case hasStartedContent
        case isTimerRunning
        case isTTSPlaying
        case decisionIndex
        case isFirstRequest
        case isInterrupted
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Log.debug("Session activated: \(activationState.rawValue)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        DispatchQueue.main.async {
            Log.debug("Received message: \(message)")
            guard let currentStage = message[messageKey.currentStage.rawValue] as? String else { return }
            
            Log.debug("stage raw value: '\(currentStage)' (type: \(type(of: currentStage)))")

            if let hasStartedContent = message[
                messageKey.hasStartedContent.rawValue] as? Bool
            {
                self.hasStartedContent = hasStartedContent
            }
            if let isTimerRunning = message[messageKey.isTimerRunning.rawValue]
                as? Bool
            {
                self.isTimerRunning = isTimerRunning
            }
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
            if let isFirstRequest = message[messageKey.isFirstRequest.rawValue]
                as? Bool
            {
                self.isFirstRequest = isFirstRequest
            }
            if let isInterrupted = message[messageKey.isInterrupted.rawValue]
                as? Bool
            {
                self.isInterrupted = isInterrupted
            }

            self.currentStage = currentStage

            switch currentStage {
            case Stage.idle.rawValue:
                self.message = [
                    "currentStage": "idle",
                    "hasStartedContent": self.hasStartedContent,
                ]
            case Stage.exposition.rawValue:
                self.message = [
                    "currentStage": "exposition",
                    "isTTSPlaying": self.isTTSPlaying,
                ]
            case Stage.decision.rawValue:
                self.message = [
                    "currentStage": "decision",
                    "isTimerRunning": self.isTimerRunning,
                    "decisionIndex": self.decisionIndex,
                    "isFirstRequest": self.isFirstRequest,
                ]
            case Stage.ending.rawValue:
                self.message = [
                    "currentStage": "ending",
                    "isTimerRunning": self.isTimerRunning,
                ]
            default:
                Log.error("wrong stage: \(currentStage)")
            }
        }
    }

    func sendStageExpositionWithPause() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["isTTSPlaying": false], replyHandler: nil)
        }
    }

    func sendStageExpositionWithResume() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["isTTSPlaying": true], replyHandler: nil)
        }
    }

    func sendFirstChoiceToIos(_ decisionIndex: Int, _ selectedChoice: String) {
        let message: [String: Any] = [
            "decisionIndex": decisionIndex,
            "selectedChoice": selectedChoice,
            "decisionCount": 1,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendSecChoiceToIos(_ decisionIndex: Int, _ selectedChoice: String) {
        let message: [String: Any] = [
            "decisionIndex": decisionIndex,
            "selectedChoice": selectedChoice,
            "decisionCount": 2,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendTimeoutToIos(_ decisionIndex: Int, isFirstRequest: Bool) {
        let message: [String: Any] = [
            "decisionIndex": decisionIndex,
            "isTimeout": true,
            "isFirstRequest": isFirstRequest,
        ]
        guard session.isReachable else { return }
        session.sendMessage(message, replyHandler: nil)
    }

    func sendFirstTimeout(_ decisionIndex: Int) {
        sendTimeoutToIos(decisionIndex, isFirstRequest: true)
    }

    func sendSecondTimeout(_ decisionIndex: Int) {
        sendTimeoutToIos(decisionIndex, isFirstRequest: false)
    }
}
