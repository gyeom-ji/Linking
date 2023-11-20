//
//  AssignsCompletionModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/04.
//

import Foundation

struct AssignsCompletionModel: Codable {
    var userName: String
    var totalAssign: Int
    var completeAssign: Int
    var completionRatio: Double
    
    
    private enum CodingKeys: String, CodingKey {
        case userName = "userName"
        case totalAssign = "totalAssign"
        case completeAssign = "completeAssign"
        case completionRatio = "completionRatio"
    }
    
    init(){
        self.userName = ""
        self.totalAssign = -1
        self.completeAssign = -1
        self.completionRatio = 0.0
    }
    
    init(userName: String, totalAssign:Int, completeAssign:Int, completionRatio:Double ){
        self.userName = userName
        self.totalAssign = totalAssign
        self.completeAssign = completeAssign
        self.completionRatio = completionRatio
    }
}
