//
//  NavigationBarWrapper.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import SwiftUI

struct NavigationBarWrapper<Content: View>: View {
    let navStyle: NavigationBarStyle
    let onTapLeft: (() -> Void)?
    let onTapRight: (() -> Void)?
    let content: Content
    
    init(navStyle: NavigationBarStyle,
         onTapLeft: (() -> Void)? = nil,
         onTapRight: (() -> Void)? = nil,
         @ViewBuilder content: () -> Content
    ) {
        self.navStyle = navStyle
        self.onTapLeft = onTapLeft
        self.onTapRight = onTapRight
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(style: navStyle, onTapLeft: onTapLeft, onTapRight: onTapRight)
            content
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

//#Preview {
//    NavigationBarWrapper()
//}
