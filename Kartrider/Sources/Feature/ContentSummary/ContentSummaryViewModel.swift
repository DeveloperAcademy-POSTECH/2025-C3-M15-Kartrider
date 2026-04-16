//
//  EndingViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation
import SwiftData

@MainActor
class ContentSummaryViewModel: ObservableObject {
    @Published var histories: [PlayHistory] = []

    private var historyRepository: PlayHistoryRepositoryProtocol?

    func configure(context: ModelContext) {
        historyRepository = PlayHistoryRepository(context: context)
    }

    func loadHistories() {
        do {
            histories = try historyRepository?.fetchAllHistories() ?? []
        } catch {
            Log.error("히스토리 로딩 실패: \(error)")
        }
    }

    func endingTitle(for history: PlayHistory) -> String {
        switch history.content.type {
        case .story:
            guard let index = history.reachedEndingIndex else { return "미완료" }
            return history.content.story?.nodes
                .first(where: { $0.type == .ending && $0.endingIndex == index })?
                .title ?? "알 수 없음"
        case .tournament:
            guard let winnerId = history.winningCandidateId else { return "미완료" }
            return history.content.tournament?.candidates
                .first(where: { $0.id == winnerId })?
                .name ?? "알 수 없음"
        }
    }

    func formattedDate(_ history: PlayHistory) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: history.startedAt)
    }
}
