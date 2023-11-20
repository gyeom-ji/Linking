//
//  CustomAlert.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/15.
//

import SwiftUI

struct CustomAlert<Content>: View where Content: View{
    let content: Content
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.3).ignoresSafeArea()
            
            content
                .background(
                    Color.white
                ).cornerRadius(10)
        }.zIndex(1)
    }
}
