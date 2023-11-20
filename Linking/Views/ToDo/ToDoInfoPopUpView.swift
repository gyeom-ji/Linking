//
//  ToDoEditPopUpView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/26.
//

import SwiftUI

struct ToDoInfoPopUpView: View {
    @Binding var showTodoInfoView: Bool
    @Binding var viewMode: ViewMode
    @EnvironmentObject var projectVM : ProjectViewModel
    @EnvironmentObject var todoVM : ToDoViewModel
    @State private var showNotEnteredAlert = false
    @State private var isChecked: Bool = false
    @State private var showPopOver: Bool = false
    @State private var alertText: String = ""
    @Binding var parentId: Int
    @State private var isAssignListChanged: Bool = false
    @State private var totalChars : Int = 0
    @State private var lastText : String = ""
    var id: Int
    
    var body: some View {
        ZStack{
            VStack{
                
                closeBtn
                
                toDoNameRow
                
                datePickerRow
                
                timePickerRow
                
                teamMemberRow
                
                buttonRow
                
                deleteBtn
                
                
                Spacer(minLength: 60)
            }
            
        }.frame(width: 600, height: 750).onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now()){
                todoVM.readTodo(id: id)
            }
            
        })
    }
}

extension ToDoInfoPopUpView {
    var closeBtn: some View {
        HStack(alignment: .center){
            Spacer()
            
            Button(action: {
                withAnimation {
                    showTodoInfoView = false
                }
                
            },
                   label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .padding(.all)
                    .foregroundColor(Color.linkingGray)
                
            }).padding(.top).buttonStyle(.borderless)
        }.padding([.top, .leading])
        
    }
    
    var toDoNameRow: some View {
        
        VStack{
            HStack(alignment: .center){
                
                Text("할 일")
                    .kerning(1)
                    .padding(.all)
                    .foregroundColor(Color.linkingLightGray)
                
                Spacer()
                
            }
            .padding([.leading])
            
            //create or update
            HStack(alignment: .center){
                
                TextField("", text: $todoVM.childTodo.content)
                    .textFieldStyle(.plain)
                    .font(.title)
                    .frame(width:530)
                    .overlay(VStack{Divider().foregroundColor(.black).offset(x: 0, y: 20)})
                    .padding(.horizontal)
                    .onChange(of: todoVM.childTodo.content){
                        text in
                        totalChars = text.count
                        
                        if totalChars <= 28 {
                                lastText = text
                        } else {
                            todoVM.childTodo.content = lastText
                        }
                    }

                Spacer()
            }
            .padding(.horizontal)
            
            HStack(alignment: .center){
                
                Spacer()
                
                Text("\(totalChars) / 28")
                    .font(.footnote)
                    .foregroundColor(.linkingLightGray)
                    .frame(alignment: .trailing)
                    .padding(.all)
                
            }
            .padding([.trailing])
        }
    }
    
    var datePickerRow: some View {
        
        HStack{
            
            CustomDatePicker(date: $todoVM.childTodo.startDate, viewMode: viewMode, titleText: "시작일", dateText: todoVM.getBeginDateToString(), startDate: Date())
            
            Spacer()
            
            CustomDatePicker(date: $todoVM.childTodo.dueDate, viewMode: viewMode, titleText: "마감일", dateText: todoVM.getDueDateToString()[0], startDate: todoVM.childTodo.startDate)
            
            Spacer()
        }.padding(.all)
        
    }
    
    var timePickerRow: some View {
        
        HStack{
            
            VStack(alignment: .leading) {
                Text("마감시간(선택사항)")
                    .kerning(1)
                    .foregroundColor(Color.linkingLightGray)
                    .padding(.leading)
                
                
                DatePicker("", selection: $todoVM.childTodo.dueDate, displayedComponents: .hourAndMinute).cornerRadius(20).padding(.leading).datePickerStyle(.compact).frame(width: 150, height: 50)
                
                
            }
            .padding(.top)
            
            Spacer()
        }.padding(.all)
        
    }
    
    var teamMemberRow: some View {
        VStack{
            HStack(alignment: .center){
                
                Text("팀원")
                    .kerning(1)
                    .foregroundColor(Color.linkingLightGray)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            HStack(alignment: .center){
                
                Button(action: {
                    showPopOver.toggle()
                }, label: {
                    Text("담당자 선택")
                        .kerning(1)
                        .padding(.all)
                        .foregroundColor(.black)
                        .background(Color(red: 0.907, green: 0.902, blue: 0.902))
                        .cornerRadius(10)
                    
                })
                .padding(.top)
                .buttonStyle(.borderless)
                .popover(isPresented: $showPopOver,attachmentAnchor: .point(.trailing), arrowEdge: .trailing, content:{
                    popOverContents()
                        .background(Color.white)
                } )
                
                Spacer()
            }
            .padding(.leading)
        }.padding(.all)
        
    }
    
    var buttonRow: some View {
        Group{
            
            Spacer()
            
            if viewMode == .create {
                Button(action: {
                    if todoVM.childTodo.content == "" {
                        alertText = "할일 명을 입력해 주세요"
                        withAnimation {
                            showNotEnteredAlert = true
                        }
                        
                    }
                    else if todoVM.childTodo.assignList.count < 1 {
                        alertText = "담당자를 선택해 주세요"
                        withAnimation {
                            showNotEnteredAlert = true
                        }
                    }
                    else {
                        todoVM.childTodo.isParent = parentId == -1 ? true : false
                        todoVM.insertTodo(parentId: parentId)
                        showTodoInfoView = false
                    }
                },
                       label: {
                    Text("생성")
                        .font(.body)
                        .kerning(1)
                        .frame(width: 50.0)
                        .padding(.all)
                        .foregroundColor(Color.white)
                        .background(Color.buttonGray)
                        .cornerRadius(10)
                }).padding(.top).buttonStyle(.borderless)
                    .alert(isPresented: $showNotEnteredAlert) {
                        Alert(title: Text(alertText),
                              dismissButton: .default(Text("확인")))
                    }
            }
            else if viewMode == .update {
                
                Button(action: {
                    if todoVM.childTodo.content == "" {
                        alertText = "할일 명을 입력해 주세요"
                        withAnimation {
                            showNotEnteredAlert = true
                        }
                        
                    }
                    else if todoVM.childTodo.assignList.count < 1 {
                        alertText = "담당자를 선택해 주세요"
                        withAnimation {
                            showNotEnteredAlert = true
                        }
                    }
                    else {
                        todoVM.updateTodo(parentId: parentId, isAssignListChanged: isAssignListChanged)
                        showTodoInfoView = false
                    }
                },
                       label: {
                    Text("수정")
                        .font(.body)
                        .kerning(1)
                        .frame(width: 50.0)
                        .padding(.all)
                        .foregroundColor(Color.white)
                        .background(Color.buttonGray)
                        .cornerRadius(10)
                }).padding(.top).buttonStyle(.borderless)
                    .alert(isPresented: $showNotEnteredAlert) {
                        Alert(title: Text(alertText),
                              dismissButton: .default(Text("확인")))
                    }
            }
        }
    }
    
    var deleteBtn: some View {
        HStack{
            Spacer()
            
            Button(action: {
                todoVM.deleteTodo(id: id, parentId: parentId)
                showTodoInfoView = false
            }, label: {
                Image(systemName: "trash")
                    .font(.title)
                    .padding(.all)
                    .foregroundColor(Color.linkingGray)
                
            }).padding(.horizontal).buttonStyle(.borderless)
        }
    }
    
    func popOverContents() -> some View {
        
        VStack{
            HStack{
                Spacer()
                Button(action: {
                    
                    showPopOver = false
                },
                       label: {
                    Image(systemName: "xmark")
                        .font(.body)
                        .padding([.top, .leading, .bottom])
                        .foregroundColor(Color.linkingGray)
                    
                }).buttonStyle(.borderless)
            }
            
            Spacer()
            
            ForEach(0..<todoVM.teamMember.count, id: \.self){ index in
                HStack {
                    Button(action: {
                        withAnimation(Animation.easeInOut(duration: 0.3)){
                            todoVM.teamMember[index].isSelected!.toggle()
                        }
                    }) {
                        HStack{
                            
                            if todoVM.teamMember[index].isSelected! {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.linkingBlue)
                                    .padding(.top, 2.0)
                                
                            } else {
                                
                                Image(systemName: "circle")
                                    .foregroundColor(.primary)
                                    .padding(.top, 2.0)
                            }
                            
                            Text(todoVM.teamMember[index].userName)
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                    }.buttonStyle(BorderlessButtonStyle())
                }
                .padding([.leading, .bottom, .trailing])
                
            }
        
            HStack{
                Spacer()
                Button(action: {
                    todoVM.childTodo.assignList.removeAll()
                    for i in 0..<todoVM.teamMember.count {
                        if todoVM.teamMember[i].isSelected! {
                            
                            if todoVM.childTodo.assignList.count > 0 && todoVM.childTodo.assignList[0].id == -1 {
                                    todoVM.childTodo.assignList[0] = AssignModel(id: 0, userId: todoVM.teamMember[i].userId, userName: todoVM.teamMember[i].userName, status: .basic)
                                }
                                else {
                                    todoVM.childTodo.assignList.append(AssignModel(id: 0, userId: todoVM.teamMember[i].userId, userName: todoVM.teamMember[i].userName, status: .basic))
                                }
                            
                            
                        }
                    }
                    isAssignListChanged = true
                    showPopOver = false
                },
                       label: {
                    Text("선택")
                        .font(.footnote)
                        .frame(width: 50.0)
                        .kerning(1)
                        .padding(.all, 10.0)
                        .foregroundColor(Color.white)
                        .background(Color.buttonGray)
                        .cornerRadius(10)
                }).padding(.vertical).buttonStyle(.borderless)
                Spacer()
            }
        }.frame(minWidth: 100)
            .padding(.horizontal)
    }
}

struct ToDoInfoPopUpView_Previews: PreviewProvider {
    @State static var modeValue = ViewMode.update
    @State static var showTodoInfoView = true
    @State static var parentId = 1
    static var previews: some View {
        ToDoInfoPopUpView(showTodoInfoView: $showTodoInfoView, viewMode: $modeValue, parentId: $parentId, id: 1)
    }
}
