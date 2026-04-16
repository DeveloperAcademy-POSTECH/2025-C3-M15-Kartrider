//
//  HomeViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation
import SwiftData

class HomeViewModel: ObservableObject {
    
    @Published var contents: [ContentMeta] = []
    @Published var selectedIndex: Int = 0
    
    private var contentRepository: ContentRepositoryProtocol?

    func configure(context: ModelContext) {
        contentRepository = ContentRepository(context: context)
    }

    func loadContents() {
        do {
            contents = try contentRepository?.fetchAllContents() ?? []
        } catch {
            Log.error("컨텐츠 로딩 실패: \(error)")
        }
    }

    func selectContent(_ selected: ContentMeta) {
        if let index = contents.firstIndex(of: selected) {
            selectedIndex = index
        }
    }
}
