//
//  UserModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/14.
//

import Foundation

struct User: Codable {
    var id : Int
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "userId"
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
    }
    
    init() {
        self.id = -1
        self.firstName = ""
        self.lastName = ""
        self.email = ""
    }
    
    init(id: Int, firstName: String, lastName: String, email: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}


struct UserResponse: Codable {
    var emailExists : Bool
    var userList: [User]
}
