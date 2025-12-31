//
//  ContentLibraryView.swift
//  Kartrider
//
//  Created by J on 6/27/25.
//

import SwiftUI

struct ContentLibraryView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.historyDetail,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                Text("[[히스토리 1 보러가기]]").onTapGesture {
                    coordinator.push(.contentSummary)
                }
                Spacer()
            }
        }
        .background(Color.brown)
    }
}

#Preview {
    ContentLibraryView()
}
