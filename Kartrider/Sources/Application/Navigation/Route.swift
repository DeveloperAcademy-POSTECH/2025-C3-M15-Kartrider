//
//  Route.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import Foundation

enum Route: Hashable {
    case home
    case intro(ContentMeta)
    case story(ContentMeta)
    case tournament(ContentMeta)
    case outro
    case contentLibrary
    case contentSummary
    case contentPlayback
}
