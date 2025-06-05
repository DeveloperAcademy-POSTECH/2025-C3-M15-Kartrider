//
//  IntroViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation

class IntroViewModel: ObservableObject {
    @Published var content: ContentMeta
    @Published var hasSentIdle: Bool = false

    init(content: ContentMeta) {
        self.content = content
        print(
            "[DEBUG] IntroViewModel 초기화 - 제목 : \(content.title), 타입 : \(content.type)"
        )
    }
    func startIfNeeded() {
            if !hasSentIdle {
                IosConnectManager.shared.sendStageIdle()
                hasSentIdle = true
            }
        }
}
