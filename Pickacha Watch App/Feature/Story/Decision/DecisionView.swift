//
//  DecisionView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/2/25.
//

import SwiftUI

struct DecisionView: View {

    @StateObject private var decisionViewModel = DecisionViewModel()

    var body: some View {
        Group {
            if decisionViewModel.isTimerRunning {
                VStack {
                    Text("손목을 돌려서 선택")
                        .font(.system(.footnote))
                    Spacer().frame(height: 20)
                    ZStack {
                        Circle()
                            .trim(from: 1 - decisionViewModel.progress, to: 1)
                            .stroke(
                                Color.orange,
                                style: StrokeStyle(
                                    lineWidth: 2, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 73, height: 73)
                            .animation(
                                .linear(duration: 1),
                                value: decisionViewModel.progress
                            )
                        Text("\(decisionViewModel.time)")
                            .font(.system(.title))
                    }
                    HStack {
                        ZStack {
                            Circle().frame(width: 36, height: 36)
                                .foregroundColor(
                                    decisionViewModel.choice == "A"
                                        ? Color.orange
                                        : Color.white.opacity(0.1))
                            Text("A").foregroundColor(.white)
                        }.padding(.leading, 19)
                        Spacer()
                        ZStack {
                            Circle().frame(width: 36, height: 36)
                                .foregroundColor(
                                    decisionViewModel.choice == "B"
                                        ? Color.orange
                                        : Color.white.opacity(0.1))
                            Text("B").foregroundColor(.white)
                        }.padding(.trailing, 19)
                    }
                }
            } else {
                if decisionViewModel.isFirstRequest {
                    ZStack {
                        Circle()
                            .stroke(
                                Color.orange,
                                style: StrokeStyle(
                                    lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 140, height: 140)
                        VStack(spacing: 16) {
                            Text("선택지가\n재생중입니다")
                                .font(.system(.headline))
                                .multilineTextAlignment(.center)

                        }
                    }
                } else {
                    ZStack {
                        Circle()
                            .stroke(
                                Color.orange,
                                style: StrokeStyle(
                                    lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 140, height: 140)
                        VStack(spacing: 10) {
                            Text("선택되지 않음")
                                .font(.system(.headline))
                                .multilineTextAlignment(.center)
                            Text("선택지가 다시 한번\n재생됩니다.")
                                .font(.system(.footnote)).foregroundStyle(
                                    Color.gray
                                )
                                .multilineTextAlignment(.center)

                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
