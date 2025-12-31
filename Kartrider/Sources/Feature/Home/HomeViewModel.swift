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
    
    private let contentRepository: ContentRepositoryProtocol
    
    init(repository: ContentRepositoryProtocol = ContentRepository()) {
        self.contentRepository = repository
    }
    
    func loadContents(context: ModelContext) {
        do {
            contents = try contentRepository.fetchAllContents(context: context)
        } catch {
            print("[ERROR] 컨텐츠 로딩 실패 : \(error)")
        }
    }
    
    func selectContent(_ selected: ContentMeta) {
        if let index = contents.firstIndex(of: selected) {
            selectedIndex = index
        }
    }
}
