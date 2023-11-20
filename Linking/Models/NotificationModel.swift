//
//  NotificationModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/17.
//

import Foundation

struct NotificationModel: Codable {
    var projectId : Int
    var body : String
    var info : String
    var priority : Int
    var noticeType : String
    var checked : Bool
    var targetId : Int
    var assistantId : Int?
    
    init(){
        self.projectId = -1
        self.body = ""
        self.info = ""
        self.priority = -1
        self.noticeType = ""
        self.checked = false
        self.targetId = -1
        self.assistantId = -1
    }
    
    init(projectId: Int, body : String, info: String, priority: Int, noticeType: String, checked: Bool, targetId: Int, assistantId: Int){
        self.projectId = projectId
        self.body = body
        self.info = info
        self.priority = priority
        self.noticeType = noticeType
        self.checked = checked
        self.targetId = targetId
        self.assistantId = assistantId
    }
}
