//
//  Seeder.swift
//  Kartrider
//
//  Created by J on 6/28/25.
//

import Foundation
import SwiftData

@MainActor
struct Seeder {
    static func seedAll(context: ModelContext) async {
        await deleteAll(context: context)
        
        do {
            try JSONParser<StoryJSON>(fileName: Constants.JSONFileName.storyEmpty).insertData(into: context)
            print("[INFO] Story 시드 완료")
        } catch {
            print("[ERROR] Story 파싱 실패: \(error)")
        }
        
        do {
            try JSONParser<TournamentJSON>(fileName: Constants.JSONFileName.tournamentData).insertData(into: context)
            print("[INFO] Tournament 시드 완료")
        } catch {
            print("[ERROR] Tournament 파싱 실패: \(error)")
        }
    }
        
    static func deleteAll(context: ModelContext) async {
        let models: [any PersistentModel.Type] = [
            ContentMeta.self,
            Story.self,
            StoryNode.self,
            StoryChoice.self,
            EndingCondition.self,
            Tournament.self,
            Candidate.self,
            PlayHistory.self,
            StoryStep.self,
            TournamentStep.self
        ]
        
        do {
            for model in models {
                try context.delete(model: model)
            }
            try context.save()
            print("[INFO] 모든 SwiftData 데이터 삭제 완료")
        } catch {
            print("[ERROR] 데이터 삭제 실패: \(error)")
        }
    }
    
    static func printState(context: ModelContext) async {
        do {
            let storyCount = try context.fetch(FetchDescriptor<Story>()).count
            let tournamentCount = try context.fetch(FetchDescriptor<Tournament>()).count
            let candidateCount = try context.fetch(FetchDescriptor<Candidate>()).count
            print("[INFO] Story: \(storyCount), Tournament: \(tournamentCount), Candidate: \(candidateCount)")
        } catch {
            print("[ERROR] 카운트 확인 실패: \(error)")
        }
    }
}
