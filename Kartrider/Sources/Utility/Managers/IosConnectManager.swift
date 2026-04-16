//
//  IosConnectManager.swift
//  Kartrider
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class IosConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    // MARK: - Properties

    static let shared = IosConnectManager()

    let session: WCSession

    @Published var isTTSPlaying: Bool = true
    @Published var decisionIndex: Int = 0
    @Published var decisionCount: Int = 0
    @Published var selectedChoice: String = ""
    @Published var selectedOption: StoryChoiceOption? = nil
    @Published var isTimeout: Bool? = false
    @Published var isFirstRequest: Bool = true

    // MARK: - Init

    private init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }

    // MARK: - Receive

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            guard let decoded = self.decode(message, as: WatchToIosMessage.self) else { return }
            if let v = decoded.isTTSPlaying { self.isTTSPlaying = v }
            if let v = decoded.decisionIndex { self.decisionIndex = v }
            if let v = decoded.decisionCount { self.decisionCount = v }
            if let v = decoded.isTimeout { self.isTimeout = v }
            if let v = decoded.isFirstRequest { self.isFirstRequest = v }
            if let raw = decoded.selectedChoice {
                self.selectedOption = StoryChoiceOption(rawValue: raw)
            }
        }
    }

    // MARK: - Send

    func sendStageIdle(retryCount: Int = 0) {
        guard retryCount < 3 else {
            Log.warning("Watch 연결 실패 — 재시도 횟수 초과")
            return
        }

        guard session.isReachable else {
            Log.warning("세션 도달 불가. 1초 뒤 재시도. (\(retryCount + 1)/3)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.sendStageIdle(retryCount: retryCount + 1)
            }
            return
        }

        Log.debug("워치로 idle 메시지 전송")
        send(["currentStage": "idle", "hasStartedContent": true])
    }

    func sendStageDecision(decisionIndex: Int, isTimerRunning: Bool, isFirstRequest: Bool) {
        send([
            "currentStage": "decision",
            "isTimerRunning": isTimerRunning,
            "decisionIndex": decisionIndex,
            "isFirstRequest": isFirstRequest,
        ])
    }

    func sendStageEnding(isTimerRunning: Bool) {
        send(["currentStage": "ending", "isTimerRunning": isTimerRunning])
    }

    func sendStageExposition(isTTSPlaying: Bool) {
        send(["currentStage": "exposition", "isTTSPlaying": isTTSPlaying])
    }

    func sendChoiceInterrupt() {
        send(["currentStage": "decision", "isInterrupted": true])
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

    // MARK: - Session Delegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {}
}

// MARK: - Message Model

private struct WatchToIosMessage: Decodable {
    var isTTSPlaying: Bool?
    var decisionIndex: Int?
    var decisionCount: Int?
    var isTimeout: Bool?
    var isFirstRequest: Bool?
    var selectedChoice: String?
}
