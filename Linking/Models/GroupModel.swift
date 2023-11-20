//
//  GroupModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import Foundation

struct PageGroup: Codable{
    var id : Int
    var projectId : Int
    var name: String
    var pageList: [PageResponse] = [PageResponse()]
    
    private enum CodingKeys: String, CodingKey {
        case id = "groupId"
        case projectId = "projectId"
        case name = "name"
        case pageList = "pageResList"
    }
    
    init(){
        self.id = -1
        self.projectId = -1
        self.name = ""
        self.pageList = [PageResponse]()
    }
    
    init(id: Int,  projectId: Int,name: String, pageList: [PageResponse]) {
        self.id = id
        self.projectId = projectId
        self.name = name
        self.pageList = pageList
    }
}

struct PageResponse: Codable{
    var id: Int
    var groupId: Int
    var pageTitle: String
    var annoNotiCnt: Int
    var template : String
    private enum CodingKeys: String, CodingKey {
        case id = "pageId"
        case groupId = "groupId"
        case pageTitle = "title"
        case annoNotiCnt = "annoNotCnt"
        case template = "template"
    }

    init(){
        self.id = -1
        self.groupId = -1
        self.pageTitle = ""
        self.annoNotiCnt = -1
        self.template = ""
    }

    init(id: Int, groupId: Int, pageTitle: String, annoNotiCnt: Int, template: String ) {
        self.id = id
        self.groupId = groupId
        self.pageTitle = pageTitle
        self.annoNotiCnt = annoNotiCnt
        self.template = template
    }
}
