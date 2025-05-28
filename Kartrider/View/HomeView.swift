//
//  HomeView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct HomeView: View {

    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            HStack {
                Spacer()
                // 보관함 버튼
                Button {
                    path.append(Route.storage)
                } label: {
                    Image(systemName: "book")
                        .font(.title)
                        .padding()
                        .foregroundColor(.black)
                }
            }
            Spacer()
            Text("[[대표 썸네일 스토리 - 눌러보세요]]").onTapGesture {
                path.append(Route.intro)
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView(path: .constant(NavigationPath()))
}
