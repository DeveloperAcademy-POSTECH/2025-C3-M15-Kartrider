//
//  IntroViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation

class IntroViewModel: ObservableObject {

    let connectManager = IosConnectManager.shared

    @Published var content: ContentMeta
    @Published var hasSentIdle: Bool = false

    init(content: ContentMeta) {
        self.content = content
    }

    func sendStageIdle() {
        connectManager.sendStageIdle()
    }

    func startContentRoute() -> Route? {
        sendStageIdle()
        switch content.type {
        case .story:
            guard content.story?.startNodeId != nil else {
                Log.error("스토리 데이터 없음")
                return nil
            }
            return .story(content)
        case .tournament:
            guard content.tournament?.id != nil else {
                Log.error("토너먼트 데이터 없음")
                return nil
            }
            return .tournament(content)
        }
    }
}
