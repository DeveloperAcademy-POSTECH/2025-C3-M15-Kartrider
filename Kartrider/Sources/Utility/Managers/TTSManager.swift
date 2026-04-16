//
//  TTSManager.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//
import Foundation
import AVFoundation

final class TTSManager: NSObject, @unchecked Sendable, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var currentContinuation: CheckedContinuation<Void, Never>?

    @MainActor @Published private(set) var state: TTSState = .inactive
    var didSpeakingStateChanged: ((Bool) -> Void)?

    private var lastUtteranceText: String?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    deinit {
        Log.debug("TTSManager deinit")
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.delegate = nil
        currentContinuation?.resume()
        currentContinuation = nil
    }

    func speakSequentially(_ text: String) async {
        guard !Task.isCancelled else { return }

        while await self.state == .paused {
            guard !Task.isCancelled else {
                return
            }
            try? await Task.sleep(for: .milliseconds(100))
        }

        let currentState = await self.state
        guard currentState == .inactive else {
            return
        }

        guard !Task.isCancelled else {
            return
        }
        
        await MainActor.run {
            self.state = .playing
        }

        lastUtteranceText = text

        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }

            self.currentContinuation = continuation
            self.speak(text)
        }
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }

    func pause() {
        guard synthesizer.isSpeaking else {
            return
        }

        _ = synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        guard synthesizer.isPaused else {
            return
        }

        let result = synthesizer.continueSpeaking()
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)

        currentContinuation?.resume()
        currentContinuation = nil

        Task { @MainActor in
            self.state = .inactive
            self.didSpeakingStateChanged?(false)
        }
    }

    func toggleSpeaking() {
        Task { @MainActor in
            switch self.state {
            case .playing:
                self.pause()
            case .paused:
                self.resume()
            case .inactive:
                if let last = self.lastUtteranceText {
                    Task {
                        await self.speakSequentially(last)
                    }
                }
            case .finished: break
            }
        }
    }
}

extension TTSManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .playing
            self.didSpeakingStateChanged?(true)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .paused
            self.didSpeakingStateChanged?(false)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .playing
            self.didSpeakingStateChanged?(true)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .inactive
            self.didSpeakingStateChanged?(false)
        }

        currentContinuation?.resume()
        currentContinuation = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .inactive
            self.didSpeakingStateChanged?(false)
        }

        currentContinuation?.resume()
        currentContinuation = nil
    }
}
