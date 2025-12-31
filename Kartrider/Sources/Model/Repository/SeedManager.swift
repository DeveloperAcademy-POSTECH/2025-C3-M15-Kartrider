//
//  SeedManager.swift
//  Kartrider
//
//  Created by J on 6/7/25.
//

import Foundation
import SwiftData

@MainActor
class SeedManager: ObservableObject {
    @Published var isReady = false
    
    let container: ModelContainer
    
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
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true // TODO: - false로 변경
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    func seedIfNeeded() async {
        let context = container.mainContext
        let isInMemory = container.configurations.first?.isStoredInMemoryOnly == true
        
        if isInMemory { // 인메모리일 경우, 무조건 시드
            await performSeeding(context: context)
            isReady = true
            return
        }
        
        let hasSeeded = UserDefaults.standard.bool(forKey: Constants.Seed.resetKey)
        
        guard !hasSeeded else {
            // UserDefaults에 true -> 종료
            isReady = true
            return
        }
        
        // UserDefaults가 false일 때만 실행
        await Seeder.deleteAll(context: context)
        
        await performSeeding(context: context)
        UserDefaults.standard.set(true, forKey: Constants.Seed.resetKey)
        isReady = true
    }

    private func performSeeding(context: ModelContext) async {
        await Seeder.seedAll(context: context)
        
        print("[DEBUG] 시드 완료 → isReady = true")
    }
}
