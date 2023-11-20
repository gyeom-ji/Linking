//
//  TableRow.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/27.
//

import SwiftUI

struct ToDoTableRow: View {
    @EnvironmentObject var todoVM : ToDoViewModel
    @EnvironmentObject var notiVM : NotificationViewModel
    @Binding var showTodoInfoView: Bool
    @Binding var viewMode: ViewMode
    @Binding var parentId: Int
    @Binding var todoId: Int
    @State private var isHover: Bool = false
    @State private var hoverId = 0
    @State private var isHoverDate: Bool = false
    @State private var falseValue: Bool = false
    @State private var dateHoverId = 0
    var todoIndex: Int
    var width: CGFloat
    
    var body: some View {
      
            VStack{
                    if todoVM.todoList.count > todoIndex {
                        ForEach(0..<todoVM.todoList[todoIndex].assignList.count, id: \.self, content: {
                            index in
                            VStack{
                                HStack{
                                    HStack{
                                        statusBtn(status: todoVM.todoList[todoIndex].assignList[index].status, id: todoVM.todoList[todoIndex].assignList[index].id, assignIndex: Int(index), childIndex: -1, userId: todoVM.todoList[todoIndex].assignList[index].userId, date: todoVM.todoList[todoIndex].dueDate)
                                        
                                        todoContentBtn(content: todoVM.todoList[todoIndex].content, isParent: true, todoId: todoVM.todoList[todoIndex].id, id: todoVM.todoList[todoIndex].assignList[Int(index)].userId, index: hoverId).onHover(perform: {
                                            hover in
                                            if hover {
                                                isHover = true
                                                hoverId = todoVM.todoList[todoIndex].id
                                            }
                                            else {
                                                isHover = false
                                                hoverId = -1
                                            }
                                        })
                                        
                                    }.frame(width: width / 3, alignment: .leading)
                                    
                                    todoDueDate(id: todoVM.todoList[todoIndex].assignList[index].id, status: todoVM.todoList[todoIndex].assignList[index].status, startDate: todoVM.getTodoListStartDateToString(index: todoIndex)[0], dueDate: todoVM.getTodoListDueDateToString(index: todoIndex)[0], dueTime: todoVM.getTodoListDueDateToString(index: todoIndex)[1] + " " + todoVM.getTodoListDueDateToString(index: todoIndex)[2])
                                    
                                    Spacer()
                                    
                                    HStack{
                                        managerName(userName: todoVM.todoList[todoIndex].assignList[index].userName)
                                        
                                        menuBtn(userId: todoVM.todoList[todoIndex].assignList[index].userId, parentId: -1, assignId: todoVM.todoList[todoIndex].assignList[index].id, todoId: todoVM.todoList[todoIndex].id, content: todoVM.todoList[todoIndex].content)
                                    }
                                }
                            }.padding(.bottom).onAppear(perform: {hoverId += 1})
                        })
                        if todoVM.todoList[todoIndex].childTodoList != nil {
                            ForEach(0..<todoVM.todoList[todoIndex].childTodoList!.count, id:\.self, content: {
                                childIndex in
                                
                                ForEach(0..<todoVM.todoList[todoIndex].childTodoList![childIndex].assignList.count, id: \.self, content: {
                                    index in
                                    VStack{
                                        HStack{
                                            HStack{
                                                statusBtn(status: todoVM.todoList[todoIndex].childTodoList![childIndex].assignList[index].status, id: todoVM.todoList[todoIndex].childTodoList![childIndex].assignList[index].id, assignIndex: Int(index), childIndex: Int(childIndex), userId: todoVM.todoList[todoIndex].childTodoList![childIndex].assignList[index].userId, date: todoVM.todoList[todoIndex].childTodoList![childIndex].dueDate)
                                                
                                                todoContentBtn(content: todoVM.todoList[todoIndex].childTodoList![childIndex].content, isParent: false, todoId: todoVM.todoList[todoIndex].childTodoList![childIndex].id, id: todoVM.todoList[todoIndex].childTodoList![childIndex].assignList[index].userId, index: hoverId).onHover(perform: {
                                                    hover in
                                                    if hover {
                                                        isHover = true
                                                        hoverId = todoVM.todoList[todoIndex].childTodoList![childIndex].id
                                                    }
                                                    else {
                                                        isHover = false
                                                        hoverId = -1
                                                    }
                                                })
                                            }.frame(width: (width / 3) - 40, alignment: .leading)
                                            
                                            todoDueDate(id:todoVM.todoList[todoIndex].childTodoList![childIndex].assignList[index].id, status: todoVM.todoList[todoIndex].childTodoList![childIndex].assignList[index].status, startDate: todoVM.getTodoListChildStartDateToString(index: todoIndex, childIndex: childIndex)[0], dueDate: todoVM.getTodoListChildDueDateToString(index: todoIndex, childIndex: childIndex)[0], dueTime: todoVM.getTodoListChildDueDateToString(index: todoIndex, childIndex: childIndex)[1] + " " + todoVM.getTodoListChildDueDateToString(index: todoIndex, childIndex: childIndex)[2])
                                            
                                            Spacer()
                                            
                                            HStack{
                                                managerName(userName: todoVM.todoList[todoIndex].childTodoList![childIndex].assignList[index].userName)
                                                
                                                menuBtn(userId: todoVM.todoList[todoIndex].childTodoList![childIndex].assignList[index].userId, parentId: todoVM.todoList[todoIndex].id, assignId: todoVM.todoList[todoIndex].childTodoList![childIndex].assignList[index].id, todoId: todoVM.todoList[todoIndex].childTodoList![childIndex].id, content: todoVM.todoList[todoIndex].childTodoList![childIndex].content)
                                            }
                                        }
                                    }.padding(.bottom).onAppear(perform: {hoverId += 1})
                                })
                                
                            }).padding(.leading, 40)
                        }
                    }
            }
            .padding([.top, .leading, .trailing])
    }
}

struct ToDoTableRow_Previews: PreviewProvider {
    @State static var value: Bool = false
    @State static var parentId: Int = 1
    @State static var todoId: Int = 1
    @State static var modeValue = ViewMode.update
    static var previews: some View {
        ToDoTableRow(showTodoInfoView: $value, viewMode: $modeValue, parentId: $parentId, todoId: $todoId, todoIndex: 1, width: CGFloat(500)).environmentObject(ToDoViewModel())
    }
}

extension ToDoTableRow {
    
    func statusBtn(status: ToDoStatus, id: Int, assignIndex: Int, childIndex: Int, userId: Int, date: Date)-> some View {
        Button(action: {
            if todoVM.userId == userId {
                    if status == .basic {
                        todoVM.changeTodoStatus(id: id, status: .progress, todoIndex: todoIndex, assignIndex: assignIndex, childIndex: childIndex)
                    }
                    else if status == .progress {
                        todoVM.changeTodoStatus(id: id, status: .complete, todoIndex: todoIndex, assignIndex: assignIndex, childIndex: childIndex)
                    }
                    else if status == .complete {
                        switch date.compare(Date()) {
                        case .orderedDescending:
                            todoVM.changeTodoStatus(id: id, status: .basic, todoIndex: todoIndex, assignIndex: assignIndex, childIndex: childIndex)
                            print("Descending")
                            break
                        case .orderedAscending:
                            todoVM.changeTodoStatus(id: id, status: .incomplete, todoIndex: todoIndex, assignIndex: assignIndex, childIndex: childIndex)
                            print("Ascending")
                            break
                        case .orderedSame:
                            todoVM.changeTodoStatus(id: id, status: .basic, todoIndex: todoIndex, assignIndex: assignIndex, childIndex: childIndex)
                            print("Same")
                            break
                        }
                    }
                    else if status == .incomplete {
                        todoVM.changeTodoStatus(id: id, status: .complete, todoIndex: todoIndex, assignIndex: assignIndex, childIndex: childIndex)
                    }
                    else if status == .incompleteProgress {
                        todoVM.changeTodoStatus(id: id, status: .complete, todoIndex: todoIndex, assignIndex: assignIndex, childIndex: childIndex)
                        
                    }
            }
        }, label: {
            Image(systemName: status == .complete ? "checkmark.circle.fill" : status == .progress || status == .incompleteProgress ? "arrow.triangle.2.circlepath" : "circle" )
                .font(.title3)
                .foregroundColor( status == .basic ? .black :  status == .incomplete || status == .incompleteProgress ? .linkingRed : .linkingBlue)
        }).buttonStyle(.borderless)
    }
    
    func managerName(userName: String) -> some View {
        Text(userName)
            .font(.title3)
            .padding(.all, 5.0)
            .kerning(1)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.lightBorder, lineWidth: 2)
            )
    }
    
    func todoDueDate(id: Int, status: ToDoStatus, startDate: String, dueDate: String, dueTime: String)-> some View {
        HStack{
            Text(dueDate)
                .font(.title3)
                .kerning(1)
                .foregroundColor(status == .incomplete || status == .incompleteProgress ? .linkingRed : .black)
                .onHover(perform: {
                    hover in
                    if hover {
                        isHoverDate = true
                        dateHoverId = id
                    }
                    else {
                        isHoverDate = false
                        dateHoverId = -1
                    }
                })
                .popover(isPresented: dateHoverId == id ? $isHoverDate : $falseValue, arrowEdge: .bottom, content: {
                    startDatePopUp(startDate: startDate).background(Color.white)
                })
            TodoDueTime(status: status, dueTime: dueTime)
        }
    }
    
    func startDatePopUp(startDate: String) -> some View {
        HStack{
            Text("시작 날짜 : \(startDate)")
                .font(.callout)
                .foregroundColor(.linkingLightGray)
                .kerning(1)
        }.frame(width: 180, height: 30)
    }
    
    func todoContentBtn(content: String, isParent: Bool, todoId: Int, id: Int, index: Int) -> some View {
        Button(action: {
            //edit View
            if todoVM.userId == id {
                viewMode = .update
                self.todoId = todoId
                withAnimation {
                    showTodoInfoView = true
                }
            }
        }, label: {
            HStack{
                Text(content)
                    .font(.title3)
                    .kerning(1)
                    .foregroundColor(.black)
                
                    Spacer()
                    
                if isHover && todoVM.userId == id && hoverId == todoId {
                    
                    HStack{
                        Image(systemName: "link")
                            .font(.callout)
                            .foregroundColor(.linkingLightGray)
                        Text("OPEN")
                            .font(.caption)
                            .kerning(1)
                            .foregroundColor(.linkingLightGray)
                    }.padding(.all, 5).overlay( RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.lightBorder, lineWidth: 2))
                }
            }
            
        }).buttonStyle(.borderless)
        
    }
    
    func menuBtn(userId: Int, parentId: Int, assignId: Int, todoId: Int, content: String) -> some View {
        Menu {
            
            Menu{
                Button(action: {
                    notiVM.insertTodoPushNotification(userId: userId, priority: 0, content: content)
                }, label: {
                    Image("circle_red")
                    Text("메일 & 앱 알림")
                })
                Button(action: {
                    notiVM.insertTodoPushNotification(userId: userId, priority: 1, content: content)
                }, label: {
                    Image("circle_green")
                    Text("앱 알림")
                })
            }label: {
                Image(systemName: "bell")
                Text("알림 보내기")
                
            }
            
            if parentId == -1 {
                Button(action: {
                    print("parentId : \(parentId)")
                    viewMode = .create
                    self.todoId = -1
                    self.parentId = todoId
                    withAnimation {
                        showTodoInfoView = true
                    }
                }, label: {
                    Image(systemName: "plus.circle")
                    
                    Text("하위 할 일 추가")
                })
            }
        } label: {
            
            Text("• • • ")
                .foregroundColor(.linkingLightGray)
        }
        .padding(.leading)
        .buttonStyle(.borderless)
        .frame(width: 50.0)
    }
}


