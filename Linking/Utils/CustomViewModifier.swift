//
//  CustomViewModifier.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/17.
//

import Foundation
import SwiftUI

struct TextModifier: ViewModifier {
    
    func body(content: Content) -> some View {
              content
            .kerning(1)
            .foregroundColor(Color.linkingLightGray)
        }
}
