//
//  ContentView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/13.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var projectVM: ProjectViewModel
    @EnvironmentObject var groupVM: GroupViewModel
    @EnvironmentObject var todoVM: ToDoViewModel
    @EnvironmentObject var notiVM: NotificationViewModel
    @EnvironmentObject var chatVM : ChatViewModel
    @ObservedObject var calendarVM = CalendarViewModel()
    @State private var showLogSignView: Bool = true
    @State private var selectedId : Int = 0
    @State private var showChatView: Bool = false
    @State private var showSideBar: Bool = false
    @State private var targetId: Int = -1
    @State private var isChangeProject : Bool = false
    
    var body: some View {

        if $showLogSignView.wrappedValue {
            withAnimation {
                LoginSignUpView(showLogSignView: $showLogSignView)
                    .background(Color.white).zIndex(1)
                    .onDisappear(  perform: {
                        DispatchQueue.main.async {

                            let userId = UserDefaults.standard.integer(forKey: "userId")
                            projectVM.readProjectList(userId: userId){
                                projectId in
                                if let projectId = projectId {
                                    print(projectId)
                                    todoVM.projectId = projectId
                                    
                                    groupVM.projectId = projectId
                                    
                                    if showSideBar {
                                        groupVM.readGroupList()
                                        groupVM.openGroupSSE()
                                    }
                                    
                                    notiVM.projectId = projectId
                                    notiVM.connectNotiWebSocket()
                                    
                                    chatVM.projectId = projectId
                                    chatVM.connectChatWebSocket()
                                    
                                    todoVM.readMonthlyTodoList(year: calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt())
                                    todoVM.getAssignsCompletionRatio()
                                    todoVM.readTodayTeamTodoList()
                                }
                            }
                        }
                    })
            }
        }
        else {
            ToolbarView(content: navigationView, showLogSignView: $showLogSignView, selectedId: $selectedId, showChatView: $showChatView, showSideBar: $showSideBar, isChangeProject: $isChangeProject).onAppear(  perform: {
                DispatchQueue.main.async {
                    if !showLogSignView {
                        let userId = UserDefaults.standard.integer(forKey: "userId")
                        projectVM.readProjectList(userId: userId){
                            projectId in
                            if let projectId = projectId {
                                print(projectId)
                                todoVM.projectId = projectId
                                
                                groupVM.projectId = projectId
                                
                                if showSideBar {
                                    groupVM.readGroupList()
                                    groupVM.openGroupSSE()
                                }
                                
                                notiVM.projectId = projectId
                                notiVM.connectNotiWebSocket()
                                
                                chatVM.projectId = projectId
                                chatVM.connectChatWebSocket()
                                
                                todoVM.readMonthlyTodoList(year: calendarVM.getCurrentYearMonth()[0], month: calendarVM.getCurrentMonthToInt())
                                todoVM.getAssignsCompletionRatio()
                                todoVM.readTodayTeamTodoList()
                            }
                        }
                    }
                }
            }).onDisappear(perform: {
                chatVM.disconnectWebSocket()
                notiVM.disconnectWebSocket()
            })
            
        }
    }
}

extension ContentView{
    
    var navigationView: some View{
        
        HStack{
            NavigationView {
                
                SideBarView(selectedId: $selectedId, showSideBar: $showSideBar, isChangeProject: $isChangeProject)

                ZStack{
                    HomeView()
                }
            }
            if showChatView {
                withAnimation {
                    ChatView(showChatView: $showChatView).frame(width: 300)
                }
            }
        }
    }
    
    func moveItem(from source: IndexSet, to destination: Int){
   
        for i in 0..<groupVM.groupList.count{
            print(groupVM.groupList[i].name)
            for j in 0..<groupVM.groupList[i].pageList.count{
                print(groupVM.groupList[i].pageList[j].pageTitle)
            }
        }
    }
    
    func removeList(at: IndexSet){
        groupVM.groupList.remove(atOffsets: at)
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var value = false
    
    static var previews: some View {
        ContentView()
    }
}
