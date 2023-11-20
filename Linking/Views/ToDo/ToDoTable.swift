//
//  ToDoTable.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/26.
//

import SwiftUI

struct ToDoTable: View {
    @EnvironmentObject var todoVM : ToDoViewModel
    @ObservedObject var calendarVM : CalendarViewModel
    @Binding var showTodoInfoView: Bool
    @Binding var viewMode: ViewMode
    @Binding var parentId: Int
    @Binding var todoId: Int
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                
                monthlyBtn
                
                VStack{
                    tableHeader
                    
                    Divider()
                    ScrollView{
                        ForEach(0..<todoVM.todoList.count, id:\.self, content: {
                            index in
                            VStack{
                                /// 상위 할일
                                ToDoTableRow(showTodoInfoView: $showTodoInfoView, viewMode: $viewMode, parentId: $parentId, todoId: $todoId, todoIndex: Int(index), width: geometry.size.width)
                                
                                Divider()
                            }
                        }).padding(.leading)
                        
                        Spacer()
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.lightBorder, lineWidth: 2)
                )
                .frame(minWidth: 600, maxHeight: 750)
            }
        }
    }
}

struct ToDoTable_Previews: PreviewProvider {
    @State static var value: Bool = false
    @State static var modeValue = ViewMode.update
    @State static var parentId: Int = 1
    @State static var todoId: Int = 1
    static var previews: some View {
        ToDoTable(calendarVM: CalendarViewModel(), showTodoInfoView: $value, viewMode: $modeValue, parentId: $parentId, todoId: $todoId).environmentObject(ToDoViewModel())
    }
}

extension ToDoTable {
    var monthlyBtn: some View {
        HStack{
            
            Spacer()
            
            Button(action: {

                todoVM.readMonthlyTodoList(year: calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt())
                calendarVM.getDayFromTodoList(todoList: todoVM.todoList)

            }, label: {
                Text("View Monthly")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.linkingGray)
                    .padding(.all, 10.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.lightBorder, lineWidth: 2)
                    )
            }).padding([.leading, .bottom]).buttonStyle(.borderless)
        }
    }
    var tableHeader: some View {
        HStack{
            Text("할 일")
                .foregroundColor(.linkingLightGray)
                .kerning(2)
                .font(.title2)
            
            Spacer()
            Spacer()
            
            Text("마감 날짜")
                .foregroundColor(.linkingLightGray)
                .kerning(2)
                .font(.title2)
            
            Spacer()

            
            Text("담당자")
                .foregroundColor(.linkingLightGray)
                .kerning(2)
                .font(.title2)
            
            Spacer()
                .frame(width: 60.0)
        }
        .padding([.top, .leading], 25)
        .padding(.bottom, 10)
    }
    
    
}
