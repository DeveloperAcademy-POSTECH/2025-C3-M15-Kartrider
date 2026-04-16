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
        await deleteContentData(context: context)

        do {
            try JSONParser<StoryJSON>(fileName: Constants.JSONFileName.storyEmpty).insertData(into: context)
            Log.debug("Story 시드 완료")
        } catch {
            Log.error("Story 파싱 실패: \(error)")
        }
        
        do {
            try JSONParser<TournamentJSON>(fileName: Constants.JSONFileName.tournamentData).insertData(into: context)
            Log.debug("Tournament 시드 완료")
        } catch {
            Log.error("Tournament 파싱 실패: \(error)")
        }
    }
        
    static func deleteContentData(context: ModelContext) async {
        let models: [any PersistentModel.Type] = [
            ContentMeta.self,
            Story.self,
            StoryNode.self,
            StoryChoice.self,
            EndingCondition.self,
            Tournament.self,
            Candidate.self,
        ]
        
        do {
            for model in models {
                try context.delete(model: model)
            }
            try context.save()
            Log.debug("모든 SwiftData 데이터 삭제 완료")
        } catch {
            Log.error("데이터 삭제 실패: \(error)")
        }
    }
}
