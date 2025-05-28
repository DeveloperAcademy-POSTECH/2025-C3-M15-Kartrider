//
//  StorageView.swift
//  Kartrider
//
//  Created by 박난 on 5/28/25.
//

import SwiftUI

struct StorageView: View {
    
    @Binding var path: NavigationPath
    
    var body: some View {
        Text("이야기 1").onTapGesture {
            // path.append()
        }
        Text("이야기 2")
    }
}

#Preview {
    StorageView(path: .constant(NavigationPath()))
}
