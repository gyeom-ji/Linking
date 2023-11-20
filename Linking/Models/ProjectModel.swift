//
//  ProjectModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/14.
//

import Foundation

struct Project: Codable {
    var id : Int
    var name: String
    var beginDate : Date = Date()
    var dueDate: Date = Date()
    var ownerId: Int
    var userList : [User] = [User()]
    
    private enum CodingKeys: String, CodingKey {
        case id = "projectId"
        case name = "projectName"
        case beginDate
        case dueDate
        case ownerId
        case userList = "partList"
    }

    init() {
        self.id = -1
        self.name = ""
        self.beginDate = Date()
        self.dueDate = Date()
        self.ownerId = -1
        self.userList = [User]()
    }
    
    init(id: Int, name: String, beginDate: Date, dueDate: Date, ownerId: Int, userList: [User]) {
        self.id = id
        self.name = name
        self.beginDate = beginDate
        self.dueDate = dueDate
        self.ownerId = ownerId
        self.userList = userList
    }
}

