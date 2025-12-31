//
//  CustomNavigationBar.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import SwiftUI

struct CustomNavigationBar: View {
    let style: NavigationBarStyle
    
    var onTapLeft: (() -> Void)? = nil
    var onTapRight: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            HStack {
                // Left
                Button {
                    onTapLeft?()
                } label: {
                    style.leftLabel
                }
                
                Spacer()
                
                // Right
                if let right = style.rightButton {
                    Button {
                        onTapRight?()
                    } label: {
                        Image(systemName: right.type.iconName)
                            .resizable()
                            .frame(width: 24, height: 20)
                            .foregroundStyle(right.color)
                    }
                } else {
                    Spacer().frame(width: 44)
                }
            }
            .padding(.horizontal, 16)
            
            // Center Title
            if let title = style.centerTitleText {
                Text(title)
                    .bold()
            }
        }
        .frame(height: 56)
    }
}

#Preview {
    VStack {
        CustomNavigationBar(style: .home)
        CustomNavigationBar(style: .intro)
        CustomNavigationBar(style: .archive, onTapLeft: {})
        CustomNavigationBar(style: .play(title: "내가 월즈 리핏 3회차 오너?!"), onTapLeft: {})
        CustomNavigationBar(style: .historyDetail).background(Color.black)
        CustomNavigationBar(style: .timeline(title: "내가 월즈 리핏 3회차 오너?!"))
    }
}
