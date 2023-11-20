//
//  PageCheckModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import Foundation

struct PageCheck: Codable{
    var id : Int
    var pageId: Int
    var userName: String
    var userId: Int
    var isEntering: Bool
    var lastChecked: Date = Date()
    var isChecked: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id = "pageCheckId"
        case pageId = "pageId"
        case userName = "userName"
        case userId = "userId"
        case lastChecked = "lastChecked"
        case isEntering = "isEntering"
        case isChecked = "isChecked"
    }
    
    init(){
        self.id = -1
        self.pageId = -1
        self.userName =  ""
        self.userId =  -1
        self.isEntering = false
        self.lastChecked = Date()
        self.isChecked = false
    }
    init(id: Int, pageId: Int,userName: String, userId: Int, isEntering:Bool, lastChecked: Date, isChecked: Bool) {
        self.id = id
        self.pageId = pageId
        self.userName = userName
        self.userId = userId
        self.isEntering = isEntering
        self.lastChecked = lastChecked
        self.isChecked = isChecked
    }
}
