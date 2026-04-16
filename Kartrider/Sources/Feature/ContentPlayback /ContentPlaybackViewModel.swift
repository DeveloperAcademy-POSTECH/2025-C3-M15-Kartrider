//
//  EndingDetailViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation
import SwiftData

@MainActor
class ContentPlaybackViewModel: ObservableObject {
    let history: PlayHistory

    init(history: PlayHistory) {
        self.history = history
    }

    // 공통
    var title: String { history.content.title }
    var thumbnailName: String? { history.content.thumbnailName }
    var contentType: ContentType { history.content.type }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: history.startedAt)
    }

    // 스토리
    var endingTitle: String {
        guard let index = history.reachedEndingIndex else { return "미완료" }
        return history.content.story?.nodes
            .first(where: { $0.type == .ending && $0.endingIndex == index })?
            .title ?? "알 수 없음"
    }

    var endingText: String {
        guard let index = history.reachedEndingIndex else { return "" }
        return history.content.story?.nodes
            .first(where: { $0.type == .ending && $0.endingIndex == index })?
            .text ?? ""
    }

    var storySteps: [StoryStep] {
        history.storySteps
            .filter { $0.type != .ending }
            .sorted { $0.timestamp < $1.timestamp }
    }

    // 토너먼트
    var winnerName: String {
        guard let winnerId = history.winningCandidateId else { return "미완료" }
        return history.content.tournament?.candidates
            .first(where: { $0.id == winnerId })?
            .name ?? "알 수 없음"
    }

    var tournamentSteps: [TournamentStep] {
        history.tournamentSteps.sorted { $0.timestamp < $1.timestamp }
    }

    var totalSelectionCount: Int {
        history.tournamentSteps.count
    }
}
