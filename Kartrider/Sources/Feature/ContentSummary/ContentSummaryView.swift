//
//  EndingView.swift
//  Kartrider
//
//  Created by 박난 on 5/28/25.
//

import SwiftUI

struct ContentSummaryView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.historyDetail,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                Text("[[전체 이야기 보기]]").onTapGesture {
                    coordinator.push(.contentPlayback)
                }
                Spacer()
            }
        }
        .background(Color.brown)
    }
}

#Preview {
    ContentSummaryView()
        .environmentObject(NavigationCoordinator())
}
