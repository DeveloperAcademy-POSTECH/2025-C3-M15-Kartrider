//
//  OutroView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct OutroView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.play(title: "임의 - 결말 페이지"),
            onTapLeft: { coordinator.popToRoot() }
        ) {
            VStack {
                Spacer()
                Text("결말 페이지")
                Spacer()
            }
        }
    }
}

#Preview {
    OutroView()
        .environmentObject(NavigationCoordinator())
}
