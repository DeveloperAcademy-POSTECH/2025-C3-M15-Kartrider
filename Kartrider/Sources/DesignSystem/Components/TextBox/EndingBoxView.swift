//
//  EndingBoxView.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//

import SwiftUI

struct EndingBoxView: View {
    let title: String
    var text: String = "이야기가 끝났습니다."
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(.primaryOrange)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primaryOrange)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.endingBackground)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    EndingBoxView(title: "절멸")
}
