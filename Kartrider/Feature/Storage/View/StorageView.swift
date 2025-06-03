//
//  StorageView.swift
//  Kartrider
//
//  Created by 박난 on 5/28/25.
//

import SwiftUI

struct StorageView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Environment(\.modelContext) private var context
    let items = ["1", "2", "3"]

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.archive,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                List {
                    ForEach(items, id: \.self) {
                        item in Text(item)
                    }.onTapGesture {
                        coordinator.push(Route.history)
                    }
                }.listStyle(PlainListStyle())
            }
        }
    }
}

#Preview {
    StorageView()
        .environmentObject(NavigationCoordinator())
}
