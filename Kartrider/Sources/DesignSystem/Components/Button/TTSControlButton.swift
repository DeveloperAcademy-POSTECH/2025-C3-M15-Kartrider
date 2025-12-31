//
//  TTSControlButton.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import SwiftUI

struct TTSControlButton: View {
    
    let isSpeaking: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: isSpeaking ? "pause.fill" : "play.fill")
                .font(.system(size: 36))
                .foregroundColor(Color.textPrimary)
        }
    }
}

#Preview {
    TTSControlButton(isSpeaking: true, onTap: {})
    TTSControlButton(isSpeaking: false, onTap: {})
}
