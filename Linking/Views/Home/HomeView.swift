//
//  HomeView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/16.
//

import SwiftUI
import Charts

struct Posting: Identifiable {
  let name: String
  let count: Int
  
  var id: String { name }
}


struct HomeView: View {
    @ObservedObject var calendarVM = CalendarViewModel()
    @EnvironmentObject var projectVM : ProjectViewModel
    @EnvironmentObject var todoVM : ToDoViewModel
    @EnvironmentObject var notiVM : NotificationViewModel
    @State private var showTodoInfoView: Bool = false
    @State private var viewMode: ViewMode = .create
    @State private var parentId: Int = -1
    @State private var todoId: Int = -1

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                
                VStack{
                    Spacer()
                    
                    HStack{
                        
                        VStack{
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            VStack{
                                toDoChartView
                                   
                                textRow(str: "할 일 완료 비율")
                                 
                            }.frame(height: geometry.size.height/7 * 3).frame(minWidth: 300, minHeight: 300).padding(.top, 20)
                            
                            GeometryReader { todoGeometry in
                                VStack{
                                    
                                    toDoTableView(width: todoGeometry.size.width)
                                    
                                    textRow(str: "오늘 할 일")
                                    
                                }.frame(height: geometry.size.height/7 * 3).frame(minWidth: 300, minHeight: 300)
                            }
                        }
                        .padding(.horizontal).frame(minWidth: 400)
                        
                        VStack{
                            
                            CalendarView(calendarVM: todoVM.calendarVM)
                                .padding(.all, 10.0).background(Color.homelightPeach).cornerRadius(30)
                            
                            textRow(str: "달력")
                            
                        }.frame(height: geometry.size.height/7 * 6).frame(minWidth: 500, minHeight: 770)
                        .padding(.horizontal)
                    }
                    
                    dueDateBar(width: geometry.size.width)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
            }.background(Color.white).onAppear(perform: {
                DispatchQueue.main.async {
                    
                    todoVM.readMonthlyTodoList(year: calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt())
                    todoVM.getAssignsCompletionRatio()
                    todoVM.readTodayTeamTodoList()
                    calendarVM.returnToday()
                }
            }).frame(minWidth: 800, minHeight: 850)
        }
    }
}

extension HomeView {
    
    var toDoChartView : some View {
        VStack{
            Chart {
                ForEach(0..<todoVM.assignsCompletionList.count, id:\.self, content: {
                    index in
                       BarMark(
                           x: .value("Name", todoVM.assignsCompletionList[index].userName),
                           y: .value("Posting", todoVM.assignsCompletionList[index].completionRatio)
                       )
                       .foregroundStyle(todoVM.assignsCompletionList[index].completionRatio < 50 ? Color.linkingRed : Color.linkingLightGreen)
                })
            }
            .padding(.all, 5.0)
     
            
        } .padding(.all).background(Color.lightGreen).cornerRadius(30)
    }
    
    func toDoTableView(width: CGFloat) -> some View {
        ScrollView {
            HStack{
                VStack{
                    ForEach(0..<todoVM.todayTeamTodoList.count, id:\.self, content: {
                        index in
                        VStack{
                            ForEach(0..<todoVM.todayTeamTodoList[index].assignList.count, id: \.self, content: {
                                assignIndex in
                                VStack{
                                    HStack{
                                        HStack{
                                            TodoStatusBtn(status: todoVM.todayTeamTodoList[index].assignList[assignIndex].status, id: todoVM.todayTeamTodoList[index].assignList[assignIndex].id, teamTodoIndex: Int(index), assignIndex: Int(assignIndex), childIndex: -1, userId:todoVM.todayTeamTodoList[index].assignList[assignIndex].userId, date: todoVM.todayTeamTodoList[index].dueDate)
                                        
                                        Text(todoVM.todayTeamTodoList[index].content)
                                            .font(.title3)
                                            .kerning(1)
                                            .foregroundColor(.black)
                                        
                                        }.frame(width: width / 3, alignment: .leading)
                                        
                                        TodoDueTime(status: todoVM.todayTeamTodoList[index].assignList[assignIndex].status, dueTime: todoVM.getTodayTeamDueDateToString(index: Int(index))[1] + " " + todoVM.getTodayTeamDueDateToString(index: Int(index))[2])
                                        
                                        Spacer()
                                        
                                        Text(todoVM.todayTeamTodoList[index].assignList[assignIndex].userName)
                                            .font(.title3)
                                            .padding(.all, 5.0)
                                            .kerning(1)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.lightBorder, lineWidth: 2)
                                            )
                                        
                                        todoBtn(userId: todoVM.todayTeamTodoList[index].assignList[assignIndex].userId, content: todoVM.todayTeamTodoList[index].content).padding(.trailing, 10)
                                    }
                                }.padding(.vertical, 10)
                            })
                            
                            if todoVM.todayTeamTodoList[index].childTodoList != nil {
                                ForEach(0..<todoVM.todayTeamTodoList[index].childTodoList!.count, id:\.self, content: {
                                    childIndex in
                                    
                                    
                                    ForEach(0..<todoVM.todayTeamTodoList[index].childTodoList![childIndex].assignList.count, id: \.self, content: {
                                        assignIndex in
                                        VStack{
                                            HStack{
                                                HStack{
                                                    TodoStatusBtn(status: todoVM.todayTeamTodoList[index].childTodoList![childIndex].assignList[assignIndex].status, id: todoVM.todayTeamTodoList[index].childTodoList![childIndex].assignList[assignIndex].id, teamTodoIndex: Int(index), assignIndex: Int(assignIndex), childIndex: Int(childIndex), userId: todoVM.todayTeamTodoList[index].childTodoList![childIndex].assignList[assignIndex].userId, date: todoVM.todayTeamTodoList[index].childTodoList![childIndex].dueDate)
                                                
                                                Text(todoVM.todayTeamTodoList[index].childTodoList![childIndex].content)
                                                    .font(.title3)
                                                    .kerning(1)
                                                    .foregroundColor(.black)
                                                
                                                }.frame(width: width / 3, alignment: .leading)
                                                
                                                TodoDueTime(status: todoVM.todayTeamTodoList[index].childTodoList![childIndex].assignList[assignIndex].status, dueTime: todoVM.getTodayTeamDueDateToString(index: Int(index))[1] + " " + todoVM.getTodayTeamDueDateToString(index: Int(index))[2])
                                                
                                                Spacer()
                                                
                                                Text(todoVM.todayTeamTodoList[index].childTodoList![childIndex].assignList[assignIndex].userName)
                                                    .font(.title3)
                                                    .padding(.all, 5.0)
                                                    .kerning(1)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.lightBorder, lineWidth: 2)
                                                    )
                                                
                                                todoBtn(userId: todoVM.todayTeamTodoList[index].childTodoList![childIndex].assignList[assignIndex].userId, content: todoVM.todayTeamTodoList[index].childTodoList![childIndex].content).padding(.trailing, 10)
                                            }
                                        }.padding(.vertical, 10)
                                    })
                                })
                            }
                            Divider()
                        }
                    }).padding(.leading)
                }
                Spacer()
            }
        }.padding([.all]).background(Color.lightYellow).cornerRadius(30)
    }
    
    func todoBtn(userId: Int, content: String) -> some View {
        Menu {
            
            Menu{
                Button(action: {
                    notiVM.insertTodoPushNotification(userId: userId, priority: 0, content: content)
                }, label: {
                    Image("circle_red")
                    Text("메일 & 웹/앱 알림")
                })
                Button(action: {
                    notiVM.insertTodoPushNotification(userId: userId, priority: 0, content: content)
                }, label: {
                    Image("circle_green")
                    Text("웹/앱 알림")
                })
            }label: {
                Image(systemName: "bell")
                Text("알림 보내기")
                
            }
        } label: {
            
            Text("• • • ")
                .foregroundColor(.linkingLightGray)
        }
        .padding(.leading)
        .buttonStyle(.borderless)
        .frame(width: 50.0)
    }
    func dueDateBar(width: CGFloat) -> some View {
        HStack
        {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.lightPeach)
                .frame(width: ((width / 10) * 9.8) * CGFloat(projectVM.percent), height: 35)
            if projectVM.percent != 1.0 {
                Spacer()
            }
        }.frame(height: 35).background(Color.homelightPeach).cornerRadius(10).overlay(
            Text(projectVM.dday)
                    .foregroundColor(.linkingLightGray)
                    .font(.callout)
                    .kerning(1)
                )
    }
    
    func tableRow(state: Int, content: String, dueDate: String, manager: String) -> some View {
        HStack{
            Button(label: {
                Image(systemName: state == 0 ? "checkmark.circle.fill" : state == 1 ? "arrow.triangle.2.circlepath" : "circle" )
                    .font(.title3)
                    .foregroundColor( state == 2 ? .black : state == 3 ? .linkingRed : .linkingBlue)
            }).buttonStyle(.borderless)
            
            
            Button(action: {
                //edit View
                viewMode = .update
                withAnimation {
                    showTodoInfoView = true
                }
                
            }, label: {
                Text(content)
                    .font(.title3)
                    .kerning(1)
                    .foregroundColor(.black)
            }).buttonStyle(.borderless)
        
            Spacer()
            Spacer()
            
            Text(dueDate)
                .font(.title3)
                .kerning(1)
                .foregroundColor( state == 3 ? .linkingRed : .black)
            Spacer()
            
            Text(manager)
                .font(.title3)
                .padding(.all, 5.0)
                .kerning(1)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.lightBorder, lineWidth: 2)
                )
        }
        .padding([.top, .leading, .trailing])
    }
    
    func textRow(str: String) -> some View {
        Text(str)
            .font(.body)
            .frame(height: 30.0)
            .kerning(1)
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView()
    }
}
