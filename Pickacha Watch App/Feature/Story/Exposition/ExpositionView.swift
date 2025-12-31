//
//  ExpositionView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/2/25.
//

import SwiftUI

struct ExpositionView: View {

    @StateObject private var expositionViewModel = ExpositionViewModel()

    var body: some View {
        ZStack {
            Circle()
                .frame(width: 102, height: 102).foregroundColor(.white)
            Image(
                systemName: expositionViewModel.isTTSPlaying
                    ? "pause.fill" : "play.fill"
            ).font(.system(size: 36, weight: .bold))
                .foregroundColor(.orange)
                .onTapGesture {
                    expositionViewModel.toggleStateWatch()
                }
        }
    }
}
