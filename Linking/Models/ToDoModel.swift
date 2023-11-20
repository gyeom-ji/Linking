//
//  ToDoModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/26.
//

import Foundation

struct ToDoModel: Codable {
    var id : Int
    var startDate : Date
    var dueDate: Date
    var content: String
    var isParent: Bool
    var assignList: [AssignModel]
    var childTodoList: [ChildToDoModel]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "todoId"
        case startDate = "startDate"
        case dueDate = "dueDate"
        case content = "content"
        case isParent = "isParent"
        case assignList = "assignList"
        case childTodoList
    }
    
    init(){
        self.id = -1
        self.startDate = Date()
        self.dueDate = Date()
        self.content = ""
        self.isParent = false
        self.assignList = [AssignModel()]
    }

    init(id: Int, startDate: Date, dueDate: Date, content: String, isParent: Bool, assignList: [AssignModel], childTodoList: [ChildToDoModel]? = nil) {
        self.id = id
        self.startDate = startDate
        self.dueDate = dueDate
        self.content = content
        self.isParent = isParent
        self.assignList = assignList
        self.childTodoList = childTodoList
    }
}

struct ChildToDoModel: Codable {
    var id : Int
    var parentId : Int?
    var startDate : Date
    var dueDate: Date
    var content: String
    var isParent: Bool
    var assignList: [AssignModel]
    
    private enum CodingKeys: String, CodingKey {
        case id = "todoId"
        case startDate = "startDate"
        case dueDate = "dueDate"
        case content = "content"
        case isParent = "isParent"
        case assignList = "assignList"
        case parentId
    }
    
    init(){
        self.id = -1
        self.startDate = Date()
        self.dueDate = Date()
        self.content = ""
        self.isParent = false
        self.assignList = [AssignModel()]
    }
    
    init(id: Int, parentId: Int? = nil, startDate: Date, dueDate: Date, content: String, isParent: Bool, assignList: [AssignModel]) {
        self.id = id
        self.parentId = parentId
        self.startDate = startDate
        self.dueDate = dueDate
        self.content = content
        self.isParent = isParent
        self.assignList = assignList
    }
}

struct MyToDoModel: Codable{
    var id : Int
    var dueDate: Date
    var content: String
    var status: ToDoStatus
    var projectName: String
    var projectId: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "assignId"
        case dueDate = "dueDate"
        case content = "content"
        case status = "status"
        case projectName = "projectName"
        case projectId = "projectId"
    }
    
    init(id: Int, dueDate: Date, content: String, status: ToDoStatus, projectName: String, projectId: Int) {
        self.id = id
        self.dueDate = dueDate
        self.content = content
        self.status = status
        self.projectName = projectName
        self.projectId = projectId
    }
    
    init(){
        self.id = -1
        self.dueDate = Date()
        self.content = ""
        self.status = .basic
        self.projectName = ""
        self.projectId = -1
    }
}

