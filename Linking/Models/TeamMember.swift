//
//  TeamMember.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/06.
//

import Foundation

struct TeamMember : Codable {
    var userId : Int
    var userName: String
    var isSelected : Bool?
    
    init(userId: Int, userName: String, isSelected: Bool? = nil) {
        self.userId = userId
        self.userName = userName
        self.isSelected = isSelected
    }
    init(){
        self.userId = -1
        self.userName = ""
    }
}
