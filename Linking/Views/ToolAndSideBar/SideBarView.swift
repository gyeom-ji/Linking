//
//  SideBar.swift
//  Linking
//
//  Created by 윤겸지 on 2023/04/06.
//

import SwiftUI
import IKEventSource

struct SideBarView: View {
    @EnvironmentObject var projectVM: ProjectViewModel
    @EnvironmentObject var groupVM: GroupViewModel
    @EnvironmentObject var pageVM : PageViewModel
    @Binding var selectedId: Int
    @State private var isEdit: Bool = false
    @State private var isShowGroupList: Bool = true
    @State private var AlertTitle: String  = ""
    @State private var popUpMessage: String  = "추가할 그룹 명을 입력해 주세요"
    @State private var showAlert: Bool = false
    @State private var showPopUp: Bool = false
    @State private var showPageEditPopUp: Bool = false
    @State private var falseValue: Bool = false
    @State private var groupName = ""
    @State private var pageTitle = ""
    @Binding var showSideBar: Bool
    @State private var type : String = ""
    @State private var targetId : Int = 0
    @State private var totalChars : Int = 0
    @State private var lastText : String = ""
    @Binding var isChangeProject : Bool
    
    var body: some View {
        ZStack{
            VStack{
                List {
                    
                    projectNameAndHomeBtnRow.onAppear(perform: {
                        showSideBar = true
                        print("showSideBar")
                    })
                    
                    toDoSection
                    
                    documentSectionHeader
                    
                    
                    if isShowGroupList {
                        //groupList
                        ForEach(0..<groupVM.getGroupListCount(), id: \.self) {
                            index in
                            
                            //pageList
                            Section(content: {
                                ForEach(0..<groupVM.getPageListCount(groupIndex: index), id: \.self) {
                                    pageIndex in
                                    HStack{
                                        NavigationLink(destination: DocumentView(pageIndex: Int(pageIndex), groupIndex: Int(index), template: groupVM.groupList[index].pageList[pageIndex].template, isChangeProject: $isChangeProject).onAppear(perform: {
                                            isChangeProject = false
                                            print("==============")
                                        })) {
                                            HStack {
                                                if isEdit {
                                                    Image(systemName: "line.3.horizontal")
                                                        .font(.system(size:15))
                                                        .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                                                        .padding(.trailing, 5)
                                                }
                                                
                                                Text(groupVM.groupList[index].pageList[pageIndex].pageTitle)
                                                    .font(.system(size:12))
                                                    .foregroundColor(.black)
                                                    .padding(.leading)
                                                    .padding(.vertical, 5)
                                                    .kerning(1)
                                                
                                                Spacer()
                                                
                                                if groupVM.groupList[index].pageList[pageIndex].annoNotiCnt > 0 {
                                                    annotationNotiIcon(index: Int(index), pageIndex: Int(pageIndex))
                                                }
                                            }
                                        }
                                        
                                        Menu {
                                            
                                            Button(action: {
                                                
                                                pageTitle = groupVM.groupList[index].pageList[pageIndex].pageTitle
                                                lastText = pageTitle
                                                totalChars = pageTitle.count
                                                type = "PAGE"
                                                popUpMessage = "수정할 페이지 제목을 입력해 주세요"
                                                AlertTitle = "페이지 제목을 입력해 주세요"
                                                showPageEditPopUp = true
                                                targetId = groupVM.groupList[index].pageList[pageIndex].id
                                            }, label: {
                                                Text("페이지 제목 수정")
                                                Image(systemName: "square.and.pencil")
                                            })
                                            
                                        } label: {
                                            
                                            Text("••• ")
                                                .font(.system(size: 12))
                                                .foregroundColor(.linkingLightGray)
                                                .padding(.trailing)
                                            
                                        }
                                        .buttonStyle(.borderless)
                                        .frame(width: 18.0)
                                    }.popover(isPresented:  targetId == groupVM.groupList[index].pageList[pageIndex].id ? $showPageEditPopUp : $falseValue, arrowEdge: .leading, content: {
                                        popUp(pageIndex: Int(pageIndex), groupIndex: Int(index)).background(Color.white)
                                    })
                                    
                                }.onMove(perform: isEdit ? {
                                    from, to in
                                    groupVM.groupList[index].pageList.move(fromOffsets: from, toOffset: to)
                                } : nil).padding(.leading, 10)
                            },header: {
                                SubListHeader(index: index, groupName: $groupVM.groupList[index].name)
                                
                            })
                            Spacer()
                                .frame(height: 10)
                            
                        }.onMove(perform: isEdit ? {
                            from, to in
                            groupVM.groupList.move(fromOffsets: from, toOffset: to)
                            
                        } : nil).padding(.leading, 15)
                        
                    }
                }.listStyle(.sidebar).background(Color.lightBeige).frame(minWidth: 200)
                
                ListFooter(isEdit: $isEdit)
            }
        }
    }
}

extension SideBarView {
    
    var projectNameAndHomeBtnRow: some View {
        NavigationLink(destination: HomeView()) {
            Text(projectVM.projectList[selectedId].name )
                .font(.system(size:17))
                .foregroundColor(Color.linkingGray)
                .kerning(2)
            
            Spacer()
            Image(systemName: "house")
                .font(.system(size:15))
                .foregroundColor(Color.linkingGray)
        }
    }
    
    var toDoSection: some View {
        Section(header: Text("작업"), content: {
            NavigationLink(destination: ToDoView()) {
                Text("할 일")
                    .font(.system(size:12))
                    .foregroundColor(.black)
                    .padding([.leading, .bottom])
                    .padding(.top, 5)
                    .kerning(1)
                
            }
        })
        .font(.system(size:12))
        .foregroundColor(Color.linkingLightGray)
        .kerning(1)
        .padding(.top, 10)
    }
    
    var documentSectionHeader: some View {
        HStack{
            Text("문서")
                .font(.system(size:12))
                .foregroundColor(Color.linkingLightGray)
                .padding(.trailing)
                .kerning(1)
            Spacer()
            
            //group insert
            Button(action: {
                type = "GROUP"
                popUpMessage = "추가할 그룹 명을 입력해 주세요"
                AlertTitle = "그룹 명을 입력해 주세요"
                groupName = ""
                lastText = groupName
                totalChars = 0
                showPopUp = true
            }, label: {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 13))
                    .foregroundColor(Color.linkingLightGray)
            }).buttonStyle(.borderless).popover(isPresented: $showPopUp, arrowEdge: .leading, content: {
                popUp(pageIndex: 0, groupIndex: 0).background(Color.white)
            })
            
            Button(action: {
                isShowGroupList.toggle()
            }, label: {
                VStack{
                    Image(systemName: isShowGroupList ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13))
                }.foregroundColor(.linkingLightGray)
            }).padding(.leading, 5).buttonStyle(.borderless)
        }.padding(.bottom, -7)
    }
    
    func annotationNotiIcon(index: Int, pageIndex: Int) -> some View {
        Text("\(groupVM.groupList[index].pageList[pageIndex].annoNotiCnt)")
            .foregroundColor(.white)
            .font(.footnote)
            .fontWeight(.medium)
            .padding(.all, 3)
            .background(Color.linkingRed)
            .clipShape(Circle())
    }
    
    func popUp(pageIndex: Int, groupIndex: Int) -> some View {
        VStack{
            HStack(alignment: .center){
                Spacer()
                
                Button(action: {
                    withAnimation {
                        if type == "GROUP" {
                            showPopUp = false
                        }
                        else {
                            showPageEditPopUp = false
                        }
                    }
                    
                },
                       label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .padding(.all)
                        .foregroundColor(Color.linkingGray)
                    
                }).padding(.all,5).buttonStyle(.borderless)
            }
            
            Text(popUpMessage)
                .font(.body)
                .foregroundColor(.linkingLightGray)
            
            
            TextField("", text: type == "GROUP" ? $groupName : $pageTitle)
                .textFieldStyle(.plain)
                .font(.body)
                .frame(width:200)
                .overlay(VStack{Divider().foregroundColor(.black).offset(x: 0, y: 20)})
                .padding(.all)
                .onSubmit {
                    if !nullCheck(text: type == "GROUP" ? groupName : pageTitle){
                        showAlert = true
                    }
                    else {
                        if type == "GROUP" {
                            groupVM.insertGroup(name: groupName)
                            showPopUp = false
                        }
                        else {
                            //edit pageName
                            groupVM.updatePageTitle(pageIndex: pageIndex, groupIndex: groupIndex, title: pageTitle)
                            showPageEditPopUp = false
                        }
                    }
                }.onChange(of:type == "GROUP" ? groupName : pageTitle ){
                    text in
                    totalChars = text.count
                    
                    if totalChars <= (type == "GROUP" ? 15 : 50) {
                            lastText = text
                    } else {
                        type == "GROUP" ?  (groupName = lastText) :  (pageTitle = lastText)
                    }
                }
            
            Text("\(totalChars) / \(type == "GROUP" ? 15 : 50)")
                .font(.footnote)
                .foregroundColor(.linkingLightGray)
                .frame(alignment: .trailing)
                .padding([.vertical])
            
            Button(action: {
                if !nullCheck(text: type == "GROUP" ? groupName : pageTitle){
                    showAlert = true
                }
                else {
                    if type == "GROUP" {
                        groupVM.insertGroup(name: groupName)
                        showPopUp = false
                    }
                    else {
                        //edit pageName
                        groupVM.updatePageTitle(pageIndex: pageIndex, groupIndex: groupIndex, title: pageTitle)
                        showPageEditPopUp = false
                    }
                }
            }, label: {
                Text("저장")
                    .font(.body)
                    .kerning(1)
                    .frame(width: 50.0)
                    .padding(.all, 10)
                    .foregroundColor(Color.linkingLightGray)
                    .background(Color.beige)
                    .cornerRadius(10)
            }).padding(.vertical).buttonStyle(.borderless).alert(isPresented: $showAlert, content: {
                Alert(title: Text(AlertTitle))
            })
            
        }
    }
    
    func nullCheck(text: String) -> Bool {
            return text == "" ? false : true
    }
}

struct SideBarView_Previews: PreviewProvider {
    @State static var selectedId : Int = 0
    @State static var showSideBar : Bool = true
    @State static var isChangeProject : Bool = true
    static var previews: some View {
        SideBarView(selectedId: $selectedId, showSideBar: $showSideBar, isChangeProject: $isChangeProject).environmentObject(ProjectViewModel()).environmentObject(GroupViewModel())
    }
}
