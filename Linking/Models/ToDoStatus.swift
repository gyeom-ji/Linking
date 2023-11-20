//
//  ToDoStatus.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/27.
//

import Foundation
import SwiftUI
import CoreData

enum ToDoStatus: String, Codable {
    case basic = "BEFORE_START"
    case progress = "IN_PROGRESS"
    case complete = "COMPLETE"
    case incomplete = "INCOMPLETE"
    case incompleteProgress = "INCOMPLETE_PROGRESS"
    case unknown
}
