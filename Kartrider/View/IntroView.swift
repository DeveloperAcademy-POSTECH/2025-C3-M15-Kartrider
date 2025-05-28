//
//  IntroView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct IntroView: View {

    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            Text("인트로페이지")
            Text("[이야기 시작하기]").onTapGesture {
                path.append(Route.story)
            }
        }
    }
}

#Preview {
    IntroView(path: .constant(NavigationPath()))
}
