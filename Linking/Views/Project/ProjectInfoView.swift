//
//  ProjectInfoView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/15.
//

import SwiftUI

struct ProjectInfoView: View {
    @EnvironmentObject var projectVM : ProjectViewModel
    var selectedId: Int
    @Binding var showProjectInfoView: Bool
    @Binding var viewMode: ViewMode
    
    init(showProjectInfoView: Binding<Bool>, viewMode: Binding<ViewMode>, selectedId: Int){
        self._showProjectInfoView = showProjectInfoView
        self._viewMode = viewMode
        self.selectedId = selectedId
    }
    
    @State private var startDate = Date()
    @State private var dueDate = Date()
    
    @State private var showSearchUserView: Bool = false
    @State private var isDelete: Bool = false
    @State private var selected = -1
    @State private var AlertTitle: String  = ""
    @State private var showAlert: Bool = false
    @State private var showUpdateCancel: Bool = false
    @State private var isMemberUpdate = false
    
    var body: some View {
        ZStack{
            
            if $showSearchUserView.wrappedValue {
                withAnimation {
                    CustomAlert(content: SearchUserView(showSearchUserView: $showSearchUserView, isMemberUpdate: $isMemberUpdate))
                }
            }
            
            VStack{
                
                closeBtn
                
                projectNameRow
                
                datePickerRow
                
                teamMemberRow
                
                buttonRow
                
                Spacer(minLength: 60)
            }
            
        }.frame(width: 600, height: viewMode == .read ? 550 : 650).onAppear(  perform: {
            DispatchQueue.main.asyncAfter(deadline: .now()){
                projectVM.readProject(index: self.viewMode == .create ? -1 : selectedId)
                print(viewMode)
            }
        })
    }
}

extension ProjectInfoView {
    
    var closeBtn: some View {
        HStack(alignment: .center){
            Spacer()
            
            Button(action: {
                print(viewMode)
                print(isMemberUpdate)
                if viewMode == .update && isMemberUpdate == true {
                    showUpdateCancel = true
                }
                
                else {
                    
                    withAnimation {
                        showProjectInfoView = false
                    }
                }
            },
                   label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .padding(.all)
                    .foregroundColor(Color.linkingGray)
                
            }).padding(.top).buttonStyle(.borderless).alert("팀원 목록을 수정하셨습니다.", isPresented: $showUpdateCancel) {
                Button("Yes", role: .destructive) {
                    //delete
                   showProjectInfoView = false
                }
            }
        message: {
            Text("수정을 취소 하시겠습니까?")
        }
        }.padding([.top, .leading])
        
    }
    
    var userRow: some View {
        Group{
            ForEach(0..<projectVM.project.userList.count, id:\.self) { index in
                
                if !(isDelete && index == 0){
                    ProjectUserRow(user: projectVM.project.userList[index])
                        .tag(index)
                }
            }
        }
    }
    
    var projectNameRow: some View {
        
        VStack{
            HStack(alignment: .center){
                
                Text("프로젝트명")
                    .kerning(1)
                    .padding(.all)
                    .foregroundColor(Color.linkingLightGray)
                
                Spacer()
                
            }
            .padding([.leading])
            
            if viewMode == .read {
                HStack(alignment: .center){
                    
                    Text(projectVM.project.name)
                        .font(.title)
                        .frame(width: 530, alignment: .leading)
                        .overlay(VStack{Divider().foregroundColor(.black).offset(x: 0, y: 20)})
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
            }
           
            else {
                // update create
                HStack(alignment: .center){
                    
                    TextField("", text: $projectVM.project.name)
                        .textFieldStyle(.plain)
                        .font(.title)
                        .frame(width:530)
                        .overlay(VStack{Divider().foregroundColor(.black).offset(x: 0, y: 20)})
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
    
    var datePickerRow: some View {
        
        HStack{
            
            CustomDatePicker(date: $projectVM.project.beginDate, viewMode: viewMode, titleText: "시작일", dateText: projectVM.getBeginDateToString(), startDate: Date())
            
            Spacer()
            
            CustomDatePicker(date: $projectVM.project.dueDate, viewMode: viewMode, titleText: "마감일", dateText: projectVM.getDueDateToString(), startDate: projectVM.project.beginDate)
            
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
                
                if viewMode != .read{
                    if isDelete == false{
                        menuBtn
                        
                    }
                    else {
                        deleteModeBtn
                    }
                }
                
            }.padding([.top, .leading, .trailing])
            
            teamListScroll
        }
        
    }
    
    var teamListScroll: some View {
        ScrollView {
            Group {
                if isDelete {
                    
                    Picker("", selection: $selected) {
                        userRow
                    }
                    .padding(.all)
                    .pickerStyle(.radioGroup)
                    
                }
                else {
                    VStack{
                        HStack{
                            Image(systemName: "crown")
                                .font(.system(size: 10))
                                .padding(.leading, 14.0)
                            Spacer()
                        }
                        userRow
                            .padding(.horizontal)
                    }
                }
            }.padding(.horizontal)
        }
        .padding(.all)
        .frame(height: 200.0)
    }
    
    var menuBtn: some View {
        Menu {
            Button("팀원 추가", action: {
                showSearchUserView = true
                print("show")
            })
            
            Button("팀원 삭제",role: .destructive, action: {
                isDelete = true
            })
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20,weight: .light))
                .foregroundColor(Color.linkingGray)
            
        }.padding(.horizontal).frame(width: 80.0).buttonStyle(.borderless)
    }
    
    var deleteModeBtn: some View {
        
        HStack{
            Button(action: {
                if selected != -1 {
                    isMemberUpdate = true
                    projectVM.project.userList.remove(at: selected)
//                    projectVM.removeUser(index: selected)
                }
                else{
                    showAlert = true
                    AlertTitle = "삭제할 팀원을 선택해 주세요"
                }
            }, label: {
                Image(systemName: "trash")
                    .font(.system(size: 15,weight: .light))
                    .foregroundColor(Color.linkingGray)
                
            }).buttonStyle(.borderless)
                .alert(isPresented: $showAlert, content: {
                    Alert(title: Text(AlertTitle))
                })
            
            Button(action: {
                isDelete = false
            }, label: {
                Text("Done")
                    .font(.system(size: 15,weight: .light))
                    .foregroundColor(Color.linkingGray)
                    .multilineTextAlignment(.center)
                    .frame(height: 40.0)
                    .kerning(1)
                
            }).padding(.horizontal).buttonStyle(.borderless)
        }
    }
    
    var buttonRow: some View {
        Group{
            
            Spacer()
            
            if viewMode == .create {
                Button(action: {
                    if projectVM.project.name == "" {
                        showAlert = true
                        AlertTitle = "프로젝트명을 입력해 주세요"
                    }
                    else {
                        projectVM.insertProject()
                       
                        showProjectInfoView = false
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
                    .alert(isPresented: $showAlert, content: {
                        Alert(title: Text(AlertTitle))
                    })
            }
            else if viewMode == .update {
                
                Button(action: {
                    if projectVM.project.name == "" {
                        showAlert = true
                        AlertTitle = "프로젝트명을 입력해 주세요"
                    }
                    else {
                        projectVM.updateProject(index: selectedId, isPartListChanged: isMemberUpdate)
                        showProjectInfoView = false
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
                    .alert(isPresented: $showAlert, content: {
                        Alert(title: Text(AlertTitle))
                    })
            }
        }
    }
}

struct ProjectInfoView_Previews: PreviewProvider {
    @ObservedObject static var userVM = UserViewModel()
    @State static var value = true
    @State static var str = ""
    @State static var modeValue = ViewMode.update
    static var previews: some View {
        ProjectInfoView(showProjectInfoView: $value, viewMode: $modeValue, selectedId: -1).environmentObject(ProjectViewModel())
    }
}
