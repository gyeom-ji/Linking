//
//  PageModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import Foundation

struct Page: Codable{
    var id: Int
    var groupId: Int
    var pageTitle: String
    var blockResList: [Block] = [Block()]
    var pageCheckResList: [PageCheck] = [PageCheck()]
    //    var contents: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "pageId"
        case groupId = "groupId"
        case pageTitle = "title"
        case blockResList = "blockResList"
        case pageCheckResList = "pageCheckResList"
    }
    
    init() {
        self.id = -1
        self.groupId = -1
        self.pageTitle = ""
        self.blockResList = [Block]()
        self.pageCheckResList = [PageCheck]()
        //        self.contents = ""
    }
    
    init(id: Int, groupId: Int, pageTitle: String, blockResList: [Block], pageCheckResList: [PageCheck]) {
        self.id = id
        self.groupId = groupId
        self.pageTitle = pageTitle
        self.blockResList = blockResList
        self.pageCheckResList = pageCheckResList
        //        self.contents = contents
    }
}

struct BlankPage: Codable {
    
    var id: Int
    var groupId: Int
    var pageTitle: String
    var pageCheckResList: [PageCheck] = [PageCheck()]
    var content: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "pageId"
        case groupId = "groupId"
        case pageTitle = "title"
        case pageCheckResList = "pageCheckResList"
        case content = "content"
    }
    
    init() {
        self.id = -1
        self.groupId = -1
        self.pageTitle = ""
        self.pageCheckResList = [PageCheck]()
        self.content = ""
    }
    
    init(id: Int, groupId: Int, pageTitle: String, pageCheckResList: [PageCheck], content: String) {
        self.id = id
        self.groupId = groupId
        self.pageTitle = pageTitle
        self.pageCheckResList = pageCheckResList
        self.content = content
    }
}
