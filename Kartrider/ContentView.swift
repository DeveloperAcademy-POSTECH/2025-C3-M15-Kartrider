//
//  ContentView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path).navigationDestination(for: Route.self) {
                route in
                switch route {
                case .home: HomeView(path: $path)
                case .intro: IntroView(path: $path)
                case .story: StoryView(path: $path)
                case .outro: OutroView(path: $path)
                case .storage: StorageView(path: $path)
                }
            }
        }

    }

}

#Preview {
    ContentView()
    //        .modelContainer(for: Item.self, inMemory: true)
}
