//
//  HomeHeaderView.swift
//  Kartrider
//
//  Created by J on 6/27/25.
//

import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("선택에 따라 바뀌는 결말!\n내가 만드는 스토리")
                .multilineTextAlignment(.center)
                .font(.title2)
                .bold()
                .foregroundColor(Color.textPrimary)
                .padding(.top, 40)
        }
    }
}

#Preview {
    HomeHeaderView()
}
