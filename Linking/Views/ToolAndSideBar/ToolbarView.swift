//
//  ToolbarView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/14.
//

import SwiftUI

struct ToolbarView<Content>: View where Content: View{
    let content: Content
    @EnvironmentObject var projectVM: ProjectViewModel
    @EnvironmentObject var pageVM: PageViewModel
    @EnvironmentObject var notiVM: NotificationViewModel
    @ObservedObject var calendarVM = CalendarViewModel()
    @EnvironmentObject var chatVM : ChatViewModel
    @EnvironmentObject var groupVM: GroupViewModel
    @EnvironmentObject var todoVM: ToDoViewModel
    
    @State private var showProjectInfoView: Bool = false
    @State private var viewMode: ViewMode = .create
    @State private var showToDoPopOver: Bool = false
    @State private var showAlarmPopOver: Bool = false
    @State private var showMainPopOver: Bool = false
    
    @Binding var showLogSignView: Bool
    @Binding var selectedId: Int
    @Binding var showChatView: Bool
    @Binding var showSideBar: Bool
    @Binding var isChangeProject : Bool
    
    let userId = UserDefaults.standard.integer(forKey: "userId")
    
    var body: some View {
        ZStack{
            if $showProjectInfoView.wrappedValue || projectVM.projectList.count < 1 || (projectVM.projectList.count > 0 && projectVM.projectList[0].id == -1) {
                CustomAlert(content: ProjectInfoView( showProjectInfoView: $showProjectInfoView, viewMode: $viewMode, selectedId: selectedId))
            }
            
            content
                .toolbar {
                    
                    if showLogSignView == false{
                        
                        ToolbarItem(placement: .principal) {
                            toolMainMenu
                        }
                        
                        ToolbarItem(placement: .navigation) {
                            sideBarBtn
                        }
                        
                        ToolbarItem( placement: .automatic) {
                            HStack {
                                Spacer()
                            }
                        }
                        
                        ToolbarItemGroup(placement: .automatic) {
                            toolTrailingBtn
                        }
                        
                    }
                    
                    else {
                        ToolbarItem(placement: .principal) {
                            Text("L I N K I N G").font(.title).fontWeight(.regular).multilineTextAlignment(.center).lineLimit(1).padding(.all)
                            
                        }
                    }
                }
        }
    }
}

extension ToolbarView{
    
    var sideBarBtn: some View {
        Button(action: toggleSidebar, label: {
            Image(systemName: "sidebar.leading")
                .resizable()
                .fontWeight(.light)
                .frame(width: 20, height: 15)
        })
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now()){
            
            showSideBar.toggle()
            
            if showSideBar {
                groupVM.projectId = projectVM.projectList[selectedId].id
                groupVM.readGroupList()
                groupVM.openGroupSSE()
            }
            else {
                groupVM.disconnectSSE()
            }
        }
    }
    
    var toolMainMenu: some View {
        
        HStack{
            Button(action: {
                showMainPopOver.toggle()
            }, label: {
                Text(projectVM.projectList.count > 0 && projectVM.projectList[0].id != -1 ? projectVM.projectList[selectedId].name : "L I N K I N G")
                    .font(.title)
                    .fontWeight(.regular)
                    .foregroundColor(Color("linkingGray"))
                    .kerning(3)
                    .multilineTextAlignment(.center)
                Image(systemName: "chevron.up.chevron.down")
            }).padding(.trailing).buttonStyle(.borderless).popover(isPresented: $showMainPopOver,attachmentAnchor: .point(.bottom), arrowEdge: .top, content:{
                mainMenuPopOverContents()
                    .background(Color.white)
            } )
        }
    }
    
    var toolTrailingBtn: some View {
        HStack{
            Button("MY TODO"){
                //my todo view
                todoVM.readTodayMyToDoList()
                showToDoPopOver.toggle()
            }
            .padding(.trailing)
            .buttonStyle(.borderless)
            .popover(isPresented: $showToDoPopOver,attachmentAnchor: .point(.bottom), arrowEdge: .top, content:{
                toDoPopOverContents()
                    .background(Color.white)
            } ).help("Show ToDos of All Projects")
            
            Button(action: {
                //alarm view
                
                showAlarmPopOver.toggle()
                notiVM.notiBadgeCount = 0
                notiVM.isNotiOpened = showAlarmPopOver
                if showAlarmPopOver == true {
                    notiVM.openNotiWebSocket()
                    notiVM.readNotificationList()
                }
                
            }){
                Image(systemName: "bell")
                    .font(.system(size: 19, weight: .light))
                    .padding(.trailing)
            } .popover(isPresented: $showAlarmPopOver, attachmentAnchor: .point(.bottom), arrowEdge: .top, content:{
                alarmPopOverContents()
                    .background(Color.white)
            } ).help("Show All Alarms").overlay(HStack(alignment: .top) {
                
                if notiVM.notiBadgeCount != 0{
                    
                    Text("\(notiVM.notiBadgeCount)")
                        .foregroundColor(.white)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .padding(.all, 3)
                        .background(Color.linkingRed)
                        .clipShape(Circle())
                }
            }.frame(maxHeight: .infinity)
            .symbolVariant(.fill)
            .symbolVariant(.circle)
            .allowsHitTesting(false)
            .offset(x: 10, y: -10))
            
            Button(action: {
                //chat view
                
                showChatView.toggle()
                chatVM.chatBadgeCount = 0
                chatVM.isChatOpened = showChatView
                if showChatView {
                    chatVM.openChatWebSocket()
                    chatVM.readChatList()
                }
                else {
                    chatVM.closeChatWebSocket()
                }
            }){
                Image(systemName: "ellipsis.message")
                    .font(.system(size: 19,weight: .light))
                    .padding(.trailing)
                    .badge(5)
                
            }.help("Open a Chat For the Project").overlay(HStack(alignment: .top) {
                
                if chatVM.chatBadgeCount != 0{
                    
                    Text("\(chatVM.chatBadgeCount)")
                        .foregroundColor(.white)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .padding(.all, 3)
                        .background(Color.linkingRed)
                        .clipShape(Circle())
                }
            }.frame(maxHeight: .infinity)
            .symbolVariant(.fill)
            .symbolVariant(.circle)
            .allowsHitTesting(false)
            .offset(x: 10, y: -10))
            
            Menu {
                
                Button(action: {
                    showProjectInfoView = true
                    viewMode = .read
                }) {
                    HStack {
                        Text("프로젝트 정보 조회")
                        Image(systemName: "info.circle")
                    }
                }
                
                if projectVM.projectList[selectedId].ownerId == userId {
                    Button(action: {
                        showProjectInfoView = true
                        viewMode = .update
                    }) {
                        HStack {
                            Text("프로젝트 정보 수정")
                            Image(systemName: "square.and.pencil")
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        projectVM.deleteProject(id: projectVM.projectList[selectedId].id, index: selectedId)
                    }) {
                        HStack {
                            Text("프로젝트 삭제")
                                .foregroundColor(.linkingRed)
                            Image("trash")
                                .foregroundColor(.linkingRed)
                        }
                    }
                }
                
            } label: {
                Label("", systemImage: "ellipsis")
                    .font(.system(size: 19,weight: .light))
                
            }.padding(.trailing).frame(width: 70.0)
        }
    }
    
    func chatBadgeIcon() -> some View {
        Text("\(chatVM.chatBadgeCount)")
            .foregroundColor(.white)
            .font(.footnote)
            .fontWeight(.medium)
            .padding(.all, 3)
            .background(Color.linkingRed)
            .clipShape(Circle())
    }
    
    func toDoPopOverContents() -> some View {
        
        VStack{
            HStack{
                Spacer()
                
                Text("오늘 할 일")
                    .font(.headline)
                    .foregroundColor(.linkingLightGray)
                    .kerning(2)
                
                Spacer()
                
            }
            .padding(.vertical)
            
            ForEach(0..<todoVM.myTodoList.count, id:\.self, content: {
                index in
                
                HStack{
                    
                    Button(action: {
                        if todoVM.myTodoList[index].status == .basic {
                            todoVM.changeMyTodoStatus(id: todoVM.myTodoList[index].id, status: .progress, myTodoIndex: Int(index))
                        }
                        else if todoVM.myTodoList[index].status == .progress {
                            todoVM.changeMyTodoStatus(id: todoVM.myTodoList[index].id, status: .complete, myTodoIndex: Int(index))
                        }
                        else if todoVM.myTodoList[index].status == .complete {
                            switch todoVM.myTodoList[index].dueDate.compare(Date()) {
                            case .orderedDescending:
                                todoVM.changeMyTodoStatus(id: todoVM.myTodoList[index].id, status: .basic, myTodoIndex: Int(index))
                                print("Descending")
                                break
                            case .orderedAscending:
                                todoVM.changeMyTodoStatus(id: todoVM.myTodoList[index].id, status: .incomplete, myTodoIndex: Int(index))
                                print("Ascending")
                                break
                            case .orderedSame:
                                todoVM.changeMyTodoStatus(id: todoVM.myTodoList[index].id, status: .basic, myTodoIndex: Int(index))
                                print("Same")
                                break
                            }
                        }
                        else if todoVM.myTodoList[index].status == .incomplete {
                            todoVM.changeMyTodoStatus(id: todoVM.myTodoList[index].id, status: .complete, myTodoIndex: Int(index))
                        }
                        else if todoVM.myTodoList[index].status == .incompleteProgress {
                            todoVM.changeMyTodoStatus(id: todoVM.myTodoList[index].id, status: .complete, myTodoIndex: Int(index))
                        }
                        
                    }, label: {
                        Image(systemName: todoVM.myTodoList[index].status == .complete ? "checkmark.circle.fill" : todoVM.myTodoList[index].status == .progress || todoVM.myTodoList[index].status == .incompleteProgress ? "arrow.triangle.2.circlepath" : "circle" )
                            .font(.title3)
                            .foregroundColor( todoVM.myTodoList[index].status == .basic ? .black :  todoVM.myTodoList[index].status == .incomplete || todoVM.myTodoList[index].status == .incompleteProgress ? .linkingRed : .linkingBlue)
                    }).buttonStyle(.borderless)
                    
                    VStack(alignment: .leading){
                        Button(action: {
                            //open todoPage
                            
                        }, label: {
                            
                            Text(todoVM.myTodoList[index].content)
                                .font(.body)
                                .kerning(1)
                                .foregroundColor(.black)
                            
                        }).padding(.leading).buttonStyle(.borderless)
                        
                        TodoDueTime(status: todoVM.myTodoList[index].status, dueTime: todoVM.getMyTodoDueDateToString(index: Int(index))[1] + " " + todoVM.getMyTodoDueDateToString(index: Int(index))[2])
                        
                        
                    }
                    Spacer()
                    
                    Text(todoVM.myTodoList[index].projectName)
                        .font(.footnote)
                        .foregroundColor(.linkingLightGray)
                    
                    Image(systemName: "link")
                        .foregroundColor(Color.linkingBlue)
                        .padding(.trailing)
                        .font(.footnote)
                }
                .padding(.bottom)
            })
            
        }.frame(minWidth: 250)
            .padding(.horizontal)
    }
    
    func alarmPopOverContents() -> some View {
        
        VStack{
            HStack{
                Spacer()
                
                Text("알림함")
                    .font(.headline)
                    .foregroundColor(.linkingLightGray)
                    .kerning(2)
                
                Spacer()
                
            }
            .padding(.vertical)
            
            ScrollView {
                ForEach(0..<notiVM.notificationList.count, id:\.self, content: {
                    index in
                    VStack{
                        HStack{
                            
                            if notiVM.notificationList[index].noticeType == "PAGE" {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(notiVM.notificationList[index].priority == 0 ? Color.linkingRed.opacity(notiVM.notificationList[index].checked ? 0.2 : 1) : Color.linkingLightGreen.opacity(notiVM.notificationList[index].checked ? 0.2 : 1))
                            }
                            else {
                                Image(systemName: "checklist")
                                    .foregroundColor(notiVM.notificationList[index].priority == 0 ? Color.linkingRed.opacity(notiVM.notificationList[index].checked ? 0.2 : 1) : Color.linkingLightGreen.opacity(notiVM.notificationList[index].checked ? 0.2 : 1))
                            }
                            
                            Text(notiVM.notificationList[index].body)
                                .font(.body)
                                .kerning(1)
                                .foregroundColor(notiVM.notificationList[index].checked ?.linkingLightGray.opacity(0.7) : .black)
                                .padding(.leading)
                            
                            Spacer()
                        }.padding(.bottom, 10)
                        
                        HStack{
                            Spacer()
                            Text(notiVM.notificationList[index].info)
                                .font(.footnote)
                                .foregroundColor(notiVM.notificationList[index].checked ?.linkingLightGray.opacity(0.3) :.linkingLightGray)
                        }
                    }.padding(.horizontal, 10).padding(.bottom, 20)
                    
                })
            }.frame(height: 300)
            
        }.frame(minWidth: 200)
            .padding(.horizontal).onDisappear(perform: {
                notiVM.closeNotiWebSocket()
            })
    }
    
    func mainMenuPopOverContents() -> some View {
        
        VStack(alignment: .leading){
            ForEach(0..<projectVM.projectList.count, id: \.self){
                index in
                
                Button(action: {
                    isChangeProject = true
                    selectedId = index
                    //chat
                    chatVM.unRegisterChatWebSocket()
                    
                    //group
                    groupVM.disconnectSSE()
                    groupVM.projectId = projectVM.projectList[selectedId].id
                    
                    if showSideBar {
                        groupVM.readGroupList()
                        groupVM.openGroupSSE()
                    }
                    
                    //project
                    projectVM.project = projectVM.projectList[selectedId]
                    projectVM.getDdayAndPercent()
                    
                    //todo
                    todoVM.projectId = projectVM.project.id
                    todoVM.readMonthlyTodoList(year: calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt())
                    todoVM.getAssignsCompletionRatio()
                    
                    calendarVM.getDayFromTodoList(todoList: todoVM.todoList)
                    todoVM.readTodayTeamTodoList()
                    
                    chatVM.projectId = projectVM.project.id
                    chatVM.registeerChatWebSocket()
                    
                    if showChatView {
                        chatVM.openChatWebSocket()
                        chatVM.readChatList()
                    }
                    //page
                    pageVM.projectId = projectVM.project.id
                    
                    //Noti
                    notiVM.projectId = projectVM.project.id
                    
                    showMainPopOver = false
                }) {
                    HStack {
                        
                        Text(projectVM.projectList[index].name)
                            .font(.system(size:18))
                            .foregroundColor(Color("linkingGray"))
                            .kerning(2)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        if selectedId == index {
                            Image(systemName: "checkmark")
                            
                        }
                    }
                }.buttonStyle(.borderless).padding(.bottom, 5)
                
            }
            
            Button( action: {
                showMainPopOver = false
                showProjectInfoView = true
                viewMode = .create
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .font(.system(size:14))
                        .foregroundColor(Color.linkingLightGray)
                    Text("프로젝트 생성")
                        .font(.system(size:14))
                        .foregroundColor(Color.linkingLightGray)
                        .kerning(2)
                }
            }.padding([.vertical, .leading] , 5).buttonStyle(.borderless)
            
        }.frame(minWidth: 200)
            .padding(.all)
    }
}
