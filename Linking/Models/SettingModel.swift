//
//  SettingModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/17.
//

import Foundation

struct SettingModel: Codable{
    var allowedWebAppPush : Bool
    var allowedMail : Bool
    
    init(){
        self.allowedMail = true
        self.allowedWebAppPush = true
    }
    
    init(allowedWebAppPush: Bool, allowedMail: Bool){
        self.allowedWebAppPush = allowedWebAppPush
        self.allowedMail = allowedMail
    }
}
