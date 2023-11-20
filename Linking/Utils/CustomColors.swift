//
//  CustomColors.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import Foundation
import SwiftUI

extension Color {
    init(hexcode: String) {
            let scanner = Scanner(string: hexcode)
            var rgbValue: UInt64 = 0
            
            scanner.scanHexInt64(&rgbValue)
            
            let red = (rgbValue & 0xff0000) >> 16
            let green = (rgbValue & 0xff00) >> 8
            let blue = rgbValue & 0xff
            
            self.init(red: Double(red) / 0xff, green: Double(green) / 0xff, blue: Double(blue) / 0xff)
            
        }
    
    static let linkingGray = Color(hexcode: "525252")
    static let linkingLightGray = Color(hexcode: "7F7F7F")
    static let buttonGray = Color(hexcode: "444545")
    static let beige = Color(hexcode: "F8F6E9")
    static let lightBeige = Color(hexcode: "FDFDFA")
    static let linkingLightGreen = Color(hexcode: "A9D18E")
    static let linkingGreen = Color(hexcode: "70AD47")
    static let lightBorder = Color(hexcode: "EDEDED")
    static let linkingRed = Color(hexcode: "FF7E79")
    static let peach = Color(hexcode: "F8CBAD")
    static let lightPeach = Color(hexcode: "FBE5D6")
    static let linkingBlue = Color(hexcode: "5B9BD5")
    static let linkingYellow = Color(hexcode: "FFE699")
    static let lightGreen = Color(hexcode: "F3F8EF")
    static let lightYellow = Color(hexcode: "FEF9E9")
    static let homelightPeach = Color(hexcode: "FBF3ED")
}
  
