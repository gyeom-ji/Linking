//
//  BlockModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import Foundation

struct Block: Codable{
    var id : Int
    var pageId: Int
    var title: String
    var content: String = ""
    var annotationList: [Annotation] = [Annotation()]
    
    private enum CodingKeys: String, CodingKey {
        case id = "blockId"
        case pageId = "pageId"
        case title = "title"
        case content = "content"
        case annotationList = "annotationResList"
    }
    
    init() {
        self.id = -1
        self.pageId = -1
        self.title = ""
        self.content = ""
        self.annotationList = [Annotation]()
    }
    
    init(id: Int, pageId: Int, title: String, content: String, annotationList: [Annotation]) {
        self.id = id
        self.pageId = pageId
        self.title = title
        self.content = content
        self.annotationList = annotationList
    }
    
}
