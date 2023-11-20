//
//  AnnotationModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import Foundation

struct Annotation: Codable{
    var id: Int
    var blockId: Int
    var userId: Int
    var userName: String
    var content: String
    var lastModified: Date = Date()
    
    private enum CodingKeys: String, CodingKey {
        case id = "annotationId"
        case blockId = "blockId"
        case userId = "userId"
        case userName = "userName"
        case content = "content"
        case lastModified = "lastModified"
    }
    
    init(){
        self.id = -1
        self.blockId = -1
        self.userId = -1
        self.userName = ""
        self.content = ""
        self.lastModified = Date()
    }
    
    init(id: Int, blockId: Int, userId: Int, userName: String, content: String, lastModified: Date) {
        self.id = id
        self.blockId = blockId
        self.userId = userId
        self.userName = userName
        self.content = content
        self.lastModified = lastModified
    }
}
