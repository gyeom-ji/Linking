//
//  CalendarViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/26.
//

import Foundation
import SwiftUI

struct DayEvent: Comparable {
    var id: Int
    var eventName: String
    var startDay : Int
    var endDay: Int
    var gap : Int
    
    init(){
        self.id = -1
        self.eventName = ""
        self.startDay = 1
        self.endDay = 1
        self.gap = 0
    }
    init(id: Int, eventName: String, startDay: Int, endDay: Int, gap: Int) {
        self.id = id
        self.eventName = eventName
        self.startDay = startDay
        self.endDay = endDay
        self.gap = gap
    }
    
    static func < (lhs: DayEvent, rhs: DayEvent) -> Bool {
        return lhs.gap > rhs.gap
    }
}

class CalendarViewModel: ObservableObject{
    @Published var currentDate: DateModel!
    @Published var dateList = [DateModel] ()
    @Published var dayEventList = [DayEvent]()
    
    let calendar = Calendar.current
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.dateFormat = "yy-MM-dd"
        return formatter
    }()
    
    init() {
        self.currentDate = DateModel(day: 0, date: Date())
        getCurrentDays()
    }
    
    func getCurrentYearMonth() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: currentDate.date)
        
        return date.components(separatedBy: " ")
    }
    
    func getCurrentYearMonthToEvent() -> [String] {

        let date = dateFormatter.string(from: currentDate.date)
        
        return date.components(separatedBy: "-")
    }
    
    func getCurrentMonthToInt() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        
        let date = formatter.string(from: currentDate.date)
        
        return date
    }
    
    func getDayFromTodoList(todoList: [ToDoModel]){
        print("todo")
        print(todoList)
        dayEventList.removeAll()
        
        for i in 0..<todoList.count{
            
            let startDay = calendar.component(.day, from: todoList[i].startDate)
            
            let tempStart = dateFormatter.string(from: todoList[i].startDate)
            let tempDue = dateFormatter.string(from: todoList[i].dueDate)
            
            if calendar.component(.month, from: todoList[i].startDate) == calendar.component(.month, from: currentDate.date){
                let betweenDays = dateFormatter.date(from: tempDue)!.timeIntervalSince(dateFormatter.date(from: tempStart)!)
                
                dayEventList.append(DayEvent(id: i, eventName: todoList[i].content, startDay: startDay , endDay: startDay + Int(betweenDays / 86400), gap: Int(betweenDays / 86400)))
            }
            else {
                let tempStart = "\(getCurrentYearMonthToEvent()[0])-\(getCurrentYearMonthToEvent()[1])-01"
                let betweenDays = dateFormatter.date(from: tempDue)!.timeIntervalSince(dateFormatter.date(from: tempStart)!)

                dayEventList.append(DayEvent(id: i, eventName: todoList[i].content, startDay: 1, endDay: 1 + Int(betweenDays / 86400), gap: Int(betweenDays / 86400)))
            }
        }
        dayEventList.sort()
        getCurrentDays()
    }
    
    func getFutureYearToInt() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        
        let date = formatter.string(from: Date())
        
        return Int(date)! + 10
    }
    
    func getPastYearToInt() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        
        let date = formatter.string(from: Date())
        
        return Int(date)! - 10
    }
    
    func changeCurrentYear(value: Int)  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        self.currentDate.date = formatter.date(from: "\(value)/\(getCurrentYearMonth()[1])")!
        
        getCurrentDays()
        
    }
    
    func changeCurrentMonth(value: Int)  {
        
        let currentMonth = calendar.date(byAdding: .month, value: value, to: currentDate.date)
        self.currentDate.date = currentMonth!
        
        getCurrentDays()
        
    }
    
    func returnToday()  {
        self.currentDate.date = Date()
        getCurrentDays()
    }
    
    func isSameDate(first: Date, second: Date) -> Bool {
        return Calendar.current.isDate(first, inSameDayAs: second)
    }
    
    func getCurrentDays() {
        DispatchQueue.main.async { [self] in
            dateList = currentDate.date.getAllDates().compactMap {
                date -> DateModel in
                
                let day = calendar.component(.day, from: date)
                var dateValue = DateModel(day: day, date: date)
                
                for i in 0..<dayEventList.count{
                    if dayEventList[i].startDay <= day && day <= dayEventList[i].endDay {
                        if dateValue.event == nil {
                            dateValue.event = [dayEventList[i]]
                        }
                        else {
                            dateValue.event?.append(dayEventList[i])
                        }
                    }
                }
                
                return dateValue
            }
            
            let startWeekday = calendar.component(.weekday, from: dateList.first?.date ?? Date()) - 1
            
            for _ in 0..<startWeekday  {
                dateList.insert(DateModel(day: -1, date: Date()), at: 0)
            }
        }
    }
}
