//
//  HistoryRowView.swift
//  Kartrider
//
//  Created by J on 4/16/26.
//

import Foundation
import SwiftUI
import SwiftData

struct HistoryRowView: View {
    let history: PlayHistory
    let endingTitle: String
    let date: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 썸네일
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Group {
                        if let thumbnailName = history.content.thumbnailName {
                            Image(thumbnailName)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                )
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                // 타이틀
                Text(history.content.title)
                    .font(.body.bold())
                    .lineLimit(2)

                // 해시태그
                HStack(spacing: 6) {
                    ForEach(history.content.hashtags.prefix(3)) { hashtag in
                        Text("#\(hashtag.value)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // 결말/우승자
                HStack(spacing: 4) {
                    Text(history.content.type == .story ? "결말" : "우승자")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(endingTitle)
                        .font(.caption.bold())
                        .foregroundStyle(Color.primaryOrange)
                }

                // 날짜
                Text("마지막 감상일 | \(date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
    }
}

#Preview {
    let schema = Schema([
        ContentMeta.self,
        PlayHistory.self,
        Story.self,
        StoryNode.self,
        StoryChoice.self,
        EndingCondition.self,
        Tournament.self,
        Candidate.self,
        StoryStep.self,
        TournamentStep.self,
        Hashtag.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext

    // 목 데이터
    let hashtags = [Hashtag(value: "시대"), Hashtag(value: "장르"), Hashtag(value: "진격거")]
    let meta = ContentMeta(
        title: "진격의 거인",
        summary: "summary",
        type: .story,
        hashtags: hashtags,
        thumbnailName: nil
    )
    context.insert(meta)

    let history = PlayHistory(content: meta)
    history.endedAt = Date()
    history.reachedEndingIndex = 1
    context.insert(history)

    return HistoryRowView(
        history: history,
        endingTitle: "조용한 기다림",
        date: "2025.05.28"
    )
    .modelContainer(container)
}
