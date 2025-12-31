//
//  LottieView.swift
//  Kartrider
//
//  Created by J on 6/9/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: animationName)
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.play()
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalTo: view.heightAnchor),
            view.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) { }
}
