//
//  BlockPageGroupModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/26.
//

import Foundation

struct BlockPageGroup: Codable {
    var groupId: Int
    var groupName: String
    var blockPageList : [BlockPage]
    
    private enum CodingKeys: String, CodingKey {
        case groupId = "groupId"
        case groupName = "name"
        case blockPageList = "pageResList"
    }
    
    init(){
        self.groupId = -1
        self.groupName = ""
        self.blockPageList = [BlockPage()]
    }
}

struct BlockPage: Codable {
    var pageId: Int
    var pageTitle: String
    var isSelected = false
    
    private enum CodingKeys: String, CodingKey {
        case pageId = "pageId"
        case pageTitle = "title"
    }
    
    init(){
        self.pageId = -1
        self.pageTitle = ""
       self.isSelected = false
    }
}
