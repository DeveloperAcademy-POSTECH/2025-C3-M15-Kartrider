//
//  WatchStartViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import AVFoundation
import Combine
import Foundation

class WatchStartViewModel: ObservableObject {

    // MARK: - Properties

    let connectManager = WatchConnectManager.shared
    private let synthesizer = AVSpeechSynthesizer()
    private var cancellable = Set<AnyCancellable>()

    // MARK: - Published

    @Published var hasStartedContent = false

    // MARK: - Init

    init() {
        connectManager.$hasStartedContent
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasStartedContent, on: self)
            .store(in: &cancellable)
    }

    // MARK: - TTS

    func speakIntro() {
        speak("이야기를 감상하려면 iPhone에서 앱을 실행해 주세요.")
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }
}
