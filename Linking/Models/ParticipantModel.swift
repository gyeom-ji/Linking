//
//  ParticipantModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/14.
//

import Foundation

struct Participant: Codable {
    let id : Int
    let project : Project
    let user : User
    
    private enum CodingKeys: String, CodingKey {
        case id = "participantId"
        case project
        case user
    }
    
    init(){
        self.id = -1
        self.project = Project()
        self.user = User()
    }
    
    init(id: Int, project: Project, user: User) {
        self.id = id
        self.project = project
        self.user = user
    }
}
