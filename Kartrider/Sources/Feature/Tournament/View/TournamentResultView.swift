//
//  TournamentResultView.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import SwiftUI

struct TournamentResultView: View {
    let winner: String
    let onNextTap: () -> Void
    
    var body: some View {
        VStack(spacing: 18) {
            DescriptionBoxView(text: "최종 우승자는?")
            
            EndingBoxView(title: winner, text: "토너먼트가 끝났습니다.")
            
            Spacer()
            
//            Text("다음 컨텐츠가 10초 후에 재생됩니다.")
//                .font(.callout)
//                .foregroundColor(Color.textSecondary)
            
//            OrangeButton(title: "다음 이야기",icon: Image(systemName: "play.fill"), action: onNextTap)
            OrangeButton(title: "홈으로",icon: Image(systemName: "home.fill"), action: onNextTap)
        }
    }
}

#Preview {
    TournamentResultView(winner: "아이스크림", onNextTap: {})
}
