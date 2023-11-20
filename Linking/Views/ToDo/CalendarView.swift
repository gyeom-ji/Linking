//
//  Test.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/25.
//

import SwiftUI


struct CalendarView: View {
    @ObservedObject var calendarVM : CalendarViewModel
    @EnvironmentObject var todoVM : ToDoViewModel
    @State private var selectedDate : Date = Date()
    @State private var showPopUp: Bool = false
    let dayOfTheWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
 
    var body: some View {
        VStack{
            calendarHeader
            
            dayOfTheWeekRow
            
            daysRow
        }
        .frame(minWidth: 500, minHeight: 750).onAppear(perform: {
            calendarVM.returnToday()
            todoVM.readMonthlyTodoList(year: todoVM.calendarVM.getCurrentYearMonth()[0], month: todoVM.calendarVM.getCurrentMonthToInt())
        })
    }
    
}

struct CalendarView_Previews: PreviewProvider {
    
    static var previews: some View {
        CalendarView(calendarVM: CalendarViewModel()).environmentObject(ToDoViewModel())
    }
}

extension CalendarView {
    var calendarHeader: some View {
        HStack {
            
            Text(calendarVM.getCurrentYearMonth()[1])
                .font(.system(size: 25))
                .fontWeight(.bold)
                .foregroundColor(.linkingGray)
                .padding(.leading)
            
            /// Change of Year
            Button(action: {
                showPopUp.toggle()
            }, label: {
                Text(calendarVM.getCurrentYearMonth()[0])
                    .font(.system(size: 23))
                    .padding(.all, 10.0)
                    .foregroundColor(.linkingGray)
                
                Image(systemName: "chevron.up.chevron.down")
            }).buttonStyle(.borderless).popover(isPresented: $showPopUp, arrowEdge: .trailing, content: {
                popUp().background(Color.white)
            })
            
            Spacer()
            
            /// Move to previous month
            Button(action: {
                
                withAnimation(Animation.easeInOut(duration: 0.3)){
                    calendarVM.changeCurrentMonth(value: -1)
                    todoVM.readMonthlyTodoList(year: calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt())
                }
                
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.linkingGray)
            }).padding(.trailing).buttonStyle(.borderless)
            
            /// Move to today
            Button(action: {
                withAnimation(Animation.easeInOut(duration: 0.3)){
                    calendarVM.returnToday()
                    selectedDate = Date()
                    todoVM.readMonthlyTodoList(year: calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt())
                }
                
            }, label: {
                Text("Today")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.linkingGray)
            }).buttonStyle(.borderless)
            
            /// Move to next month
            Button(action: {
                withAnimation(Animation.easeInOut(duration: 0.3)){
                    calendarVM.changeCurrentMonth(value: 1)
                    todoVM.readMonthlyTodoList(year: calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt())
                }
            }, label: {
                Image(systemName: "chevron.right")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.linkingGray)
            }).padding(.horizontal).buttonStyle(.borderless)
            
        }
        .padding([.top, .leading, .trailing])
    }
    
    var dayOfTheWeekRow: some View {
        HStack{
            
            ForEach(dayOfTheWeek, id:\.self, content: {
                day in
                Text(day)
                    .foregroundColor(.linkingLightGray)
                    .font(.callout)
                    .padding(.vertical, 5.0)
                    .frame(maxWidth: .infinity)
            })
        }
        .border(Color.linkingLightGray, width: 1)
    }
    
    var daysRow: some View {
        
        HStack{
            GeometryReader { geometry in
            LazyVGrid(columns: columns, spacing: 20) {
                
                    ForEach(0..<calendarVM.dateList.count , id:\.self, content: {
                        index in
                        
                        HStack{
        
                            VStack{
                                
                                dayGrid(date: calendarVM.dateList[index]).frame(height: 83.3)
                                
                                Spacer()
                                
                                Divider()
                                
                            }.overlay(todoEventLine(date: calendarVM.dateList[index], dayCount: Int(index), width: geometry.size.width))
                            Divider()
                            
                        }
                        
                    })
            }.padding(.leading, 7)
            }
        }
        .padding(.top)
    }
    func todoEventLine(date: DateModel, dayCount: Int, width: CGFloat) -> some View {
        VStack{
            if date.event != nil {
                if date.event!.count > 0 && calendarVM.dayEventList.count > 0 {
                        HStack{
                          
                            if date.day == date.event![0].startDay {
                                RoundedRectangle(cornerRadius: 5).fill(Color.linkingYellow).frame(width: width/8, height: 18).padding(.leading, 15).overlay(Text(date.event![0].eventName).padding(.leading, 15))
                                
                            }
                            else if date.day > date.event![0].startDay && date.day < date.event![0].endDay {
                                Rectangle().fill(Color.linkingYellow).frame(width: width/7, height: 18).overlay(Text(dayCount % 7 == 0 || calendarVM.dayEventList[0].id != date.event![0].id ? date.event![0].eventName : "").padding(.leading, 15))
                            }

                           else if date.day == date.event![0].endDay {
                                RoundedRectangle(cornerRadius: 5).fill(Color.linkingYellow).frame(width: width/8, height: 18).padding(.trailing, 15).overlay(Text(dayCount % 7 == 0 ? date.event![0].eventName : "").padding(.leading, 15))
                            }
                        }.padding(.top, 10)
                }
                    Text(date.event!.count > 1 ? "\(date.event!.count - 1) more..." : " ")
                        .foregroundColor(.linkingLightGray)
                        .font(.caption)
            }
        }
    }
    
    func dayGrid(date: DateModel) -> some View {
        
        VStack{
            Button(action: {
                if date.day != -1 {
                    selectedDate = date.date
                    todoVM.readDailyTodoList(year:calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt(), day: date.day)
                }
            }, label: {
                Text(date.day != -1 ? "\(date.day)" : "")
                    .font(.body)
                    .padding(.trailing)
                
            }).buttonStyle(.borderless)
                .background(
                    Circle()
                        .fill(date.day != -1 && calendarVM.isSameDate(first: date.date, second: Date.now) ? Color.peach : date.day != -1 && calendarVM.isSameDate(first: date.date, second: selectedDate) ?  Color.linkingLightGreen : .clear )
                        .frame(width: 25, height: 25)
                        .padding(.trailing)
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
        
            Spacer()
        }
    }
    
    /// Change of year
    func popUp() -> some View {
        VStack{
            
            ScrollView {
                ForEach(2010..<2030) {
                    years in
                    Button(action: {
                        calendarVM.changeCurrentYear(value: years)
                        todoVM.readMonthlyTodoList(year: calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt())
                        showPopUp = false
                    }, label: {
                        if calendarVM.getCurrentYearMonth()[0] == String(years){
                            Image(systemName: "checkmark")
                                .foregroundColor(.linkingGray)
                        }
                        else {
                            Spacer()
                                .frame(width: 12)
                        }
                        Text(String(years))
                            .font(.system(size: 20))
                            .padding(.all, 10)
                            .foregroundColor(.linkingGray)
                        
                    }).buttonStyle(.borderless)
                    Divider()
                }
            }
        }.frame(width: 150, height: 300)
    }
}
