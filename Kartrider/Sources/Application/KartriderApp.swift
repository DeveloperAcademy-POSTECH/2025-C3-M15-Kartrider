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

    @StateObject private var seedManager = SeedManager()

    var body: some Scene {
        WindowGroup {
            if seedManager.isReady {
                AppNavigationView()
                    .modelContainer(seedManager.container)
            } else {
                LaunchView()
                    .task {
                        await seedManager.seedIfNeeded()
                    }
            }
        }
    }
}
