//
//  AssignModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/07.
//

import Foundation

struct AssignModel: Codable{
    var id: Int
    var userId: Int
    var userName: String
    var status: ToDoStatus
    
    private enum CodingKeys: String, CodingKey {
        case id = "assignId"
        case userId = "userId"
        case userName = "userName"
        case status = "status"
    }
    
    init(){
        self.id = -1
        self.userId = -1
        self.userName = ""
        self.status = .basic
    }
    
    init(id: Int, userId: Int, userName: String, status: ToDoStatus) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.status = status
    }
}
