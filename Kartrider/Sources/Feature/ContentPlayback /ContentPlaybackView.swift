//
//  EndingDetailView.swift
//  Kartrider
//
//  Created by 박난 on 5/28/25.
//

import SwiftUI

struct ContentPlaybackView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.timeline(title: "임의-타임라인"),
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                Text("타임라인 뷰")
                Spacer()
            }
        }
    }
}

#Preview {
    ContentPlaybackView()
        .environmentObject(NavigationCoordinator())
}
