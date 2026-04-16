//
//  KartriderApp.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftData
import SwiftUI

@main
struct KartriderApp: App {

    let container: ModelContainer
    @State private var isReady = false

    init() {
        let schema = Schema([
            ContentMeta.self,
            Story.self,
            StoryNode.self,
            StoryChoice.self,
            EndingCondition.self,
            Tournament.self,
            Candidate.self,
            PlayHistory.self,
            StoryStep.self,
            TournamentStep.self,
        ])

        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if isReady {
                AppNavigationView()
                    .modelContainer(container)
            } else {
                LaunchView()
                    .task {
                        await seedIfNeeded()
                        isReady = true
                    }
            }
        }
    }

    @MainActor
    private func seedIfNeeded() async {
        let context = container.mainContext
        let currentVersion = Constants.Seed.version

        let savedVersion = UserDefaults.standard.string(forKey: Constants.Seed.versionKey)

        guard savedVersion != currentVersion else {
            Log.info("시드 최신 버전 — 스킵 (\(currentVersion))")
            return
        }

        Log.info("시드 버전 변경 감지: \(savedVersion ?? "없음") → \(currentVersion)")
        await Seeder.seedAll(context: context)
        UserDefaults.standard.set(currentVersion, forKey: Constants.Seed.versionKey)
    }
}
