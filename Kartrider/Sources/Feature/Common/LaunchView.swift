//
//  LaunchView.swift
//  Kartrider
//
//  Created by J on 6/5/25.
//

import SwiftUI
import Lottie

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color.primaryOrange
                .edgesIgnoringSafeArea(.all)
            
            LottieView(animationName: "launch_lottie", loopMode: .playOnce)
                .frame(width: 300, height: 300)
        }
        
    }
}

#Preview {
    LaunchView()
}
