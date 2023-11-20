//
//  File.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/23.
//

import Foundation

struct ChatModel: Codable, Identifiable {
    var id = UUID()
    var userName: String
    var firstName: String
    var content: String
    var sentDatetime: String

    private enum CodingKeys: String, CodingKey {
            case userName
            case firstName
        case content
        case sentDatetime
        }
    
    init(){
        self.userName = ""
        self.firstName = ""
        self.content = ""
        self.sentDatetime = ""
    }
    init(firstName:String, userName: String, content: String, sentDatetime: String){
       
        self.firstName = firstName
        self.userName = userName
        self.content = content
        self.sentDatetime = sentDatetime
    }
}

