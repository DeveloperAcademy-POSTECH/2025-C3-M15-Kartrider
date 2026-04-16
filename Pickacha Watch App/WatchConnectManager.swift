//
//  WatchConnectManager.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class WatchConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    // MARK: - Properties

    static let shared = WatchConnectManager()

    let session: WCSession

    @Published var currentStage: String = ""
    @Published var hasStartedContent: Bool = false
    @Published var isTimerRunning: Bool = false
    @Published var isTTSPlaying: Bool = true
    @Published var decisionIndex: Int = 0
    @Published var isFirstRequest: Bool = false
    @Published var isInterrupted: Bool = false

    // MARK: - Init

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

    // MARK: - Receive

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Log.debug("Session activated: \(activationState.rawValue)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            Log.debug("Received message: \(message)")

            guard let decoded = self.decode(message, as: IosToWatchMessage.self),
                  let currentStage = decoded.currentStage
            else { return }

            if let v = decoded.hasStartedContent { self.hasStartedContent = v }
            if let v = decoded.isTimerRunning { self.isTimerRunning = v }
            if let v = decoded.isTTSPlaying { self.isTTSPlaying = v }
            if let v = decoded.decisionIndex { self.decisionIndex = v }
            if let v = decoded.isFirstRequest { self.isFirstRequest = v }
            if let v = decoded.isInterrupted { self.isInterrupted = v }

            self.currentStage = currentStage
        }
    }

    // MARK: - Send

    func sendStageExposition(isTTSPlaying: Bool) {
        send(["isTTSPlaying": isTTSPlaying])
    }

    func sendChoiceToIos(_ decisionIndex: Int, _ selectedChoice: String, decisionCount: Int) {
        send([
            "decisionIndex": decisionIndex,
            "selectedChoice": selectedChoice,
            "decisionCount": decisionCount,
        ])
    }

    func sendTimeoutToIos(_ decisionIndex: Int, isFirstRequest: Bool) {
        send([
            "decisionIndex": decisionIndex,
            "isTimeout": true,
            "isFirstRequest": isFirstRequest,
        ])
    }

    // MARK: - Private

    private func send(_ message: [String: Any]) {
        guard session.isReachable else { return }
        session.sendMessage(message, replyHandler: nil)
    }

    private func decode<T: Decodable>(_ message: [String: Any], as type: T.Type) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: message) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Message Model

private struct IosToWatchMessage: Decodable {
    var currentStage: String?
    var hasStartedContent: Bool?
    var isTimerRunning: Bool?
    var isTTSPlaying: Bool?
    var decisionIndex: Int?
    var isFirstRequest: Bool?
    var isInterrupted: Bool?
}
