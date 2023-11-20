//
//  ToDoView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/25.
//

import SwiftUI

struct ToDoView: View {
    @EnvironmentObject var todoVM : ToDoViewModel
    @State private var currentDate: Date = Date()
    @State private var showTodoInfoView: Bool = false
    @State private var viewMode: ViewMode = .create
    @State private var parentId: Int = -1
    @State private var todoId: Int = -1
    
    var body: some View{
        ZStack{
            if $showTodoInfoView.wrappedValue {
                withAnimation {
                    CustomAlert(content: ToDoInfoPopUpView(showTodoInfoView: $showTodoInfoView, viewMode: $viewMode, parentId: $parentId, id: todoId))
                }
            }
            VStack{
                
                todoHeader
                    .padding(.top)
                
                HStack{
                    
                    VStack{
                        CalendarView(calendarVM: todoVM.calendarVM)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.lightBorder, lineWidth: 2)
                            )
                            .padding([.leading, .bottom, .trailing], 30.0)
                            .padding(.top, 70)
                            .border(.white, width: 10)
                    }
                    
                    Spacer()
                    
                    VStack{
                        ToDoTable(calendarVM: todoVM.calendarVM, showTodoInfoView: $showTodoInfoView, viewMode: $viewMode, parentId: $parentId, todoId: $todoId)
                                .padding([.leading, .bottom, .trailing], 30.0)
                    }
                }
                Spacer()
            }
        }.background(Color.white).onAppear(perform: {
            todoVM.openTodoSSE()
        }).onDisappear(perform: {
            todoVM.disconnectSSE()
        })
    }
}

struct ToDoView_Previews: PreviewProvider {
    @State static var value: Date = Date()
    static var previews: some View {
        ToDoView()
    }
}

extension ToDoView {
    var todoHeader : some View {
        HStack{
            Spacer()
            Text("할 일")
                .font(.system(size: 30))
                .kerning(2)
           
            Button(action: {
                viewMode = .create
                todoId = -1
                parentId = -1
                withAnimation {
                    showTodoInfoView = true
                }

            }, label: {
                VStack{
                    Image(systemName: "plus.circle")
                        .padding(.bottom, 1.0)
                        .font(.system(size: 30))
                        .fontWeight(.thin)

                }.foregroundColor(.linkingLightGray)
            }).padding(.leading).buttonStyle(.borderless)
            
            Spacer()
        
        }
        .padding(.vertical)
    }
}
