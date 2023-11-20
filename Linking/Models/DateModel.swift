//
//  DateModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/25.
//

import Foundation 

struct DateModel: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
    var event: [DayEvent]?
}
