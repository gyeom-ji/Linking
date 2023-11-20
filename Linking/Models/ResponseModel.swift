//
//  ResponseModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/04/06.
//

import Foundation

struct ResponseModel<T : Codable>: Codable {
    var data: T?
    var message: String
    var status: Int
}

struct WebSocketResponseModel<T : Codable>: Codable {
    var type: String
    var data: T?
}
