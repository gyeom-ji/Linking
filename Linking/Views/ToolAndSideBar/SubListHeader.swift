//
//  SubListHeader.swift
//  Linking
//
//  Created by 윤겸지 on 2023/04/06.
//

import SwiftUI

struct SubListHeader: View {
    
    var index: Int
    @Binding var groupName: String
    @State private var showPopUp: Bool = false
    @EnvironmentObject var projectVM: ProjectViewModel
    @EnvironmentObject var groupVM: GroupViewModel
    @State private var showAlert: Bool = false
    @State private var AlertTitle: String  = ""
    @State private var popUpMessage: String  = ""
    @State private var type : String = ""
    @State private var deleteAlert: Bool = false
    @State private var pageTitle: String = ""
    @State private var selectedTemplates: String = ""
    @State private var newGroupName: String = ""
    @State private var totalChars : Int = 0
    @State private var lastText : String = ""
    
    var body: some View {
        ZStack{
            HStack{
                Text(groupName)
                    .font(.system(size:12.5))
                    .foregroundColor(.linkingGray)
                    .padding(.leading)
                    .padding(.bottom, 5)
                    .kerning(1)
                
                Spacer()
                
                menuBtn

            }
        }.popover(isPresented: $showPopUp, arrowEdge: .leading, content: {
            popUp().background(Color.white)
        })
        .alert("그룹에 포함된 문서도 함께 삭제 됩니다.", isPresented: $deleteAlert) {
            
            Button("Delete", role: .destructive) {
                groupVM.deleteGroup(id: groupVM.groupList[index].id, index: index)
            }
            
        } message: {
            Text("삭제 하시겠습니까?")
        }
    }
}

extension SubListHeader {
    
    var menuBtn: some View {
        Menu {
            
            Button(action: {
                type = "PAGE"
                selectedTemplates = "BLANK"
                pageTitle = ""
                lastText = ""
                totalChars = 0
                popUpMessage = "문서 템플릿 선택 후 제목을 입력해주세요"
                AlertTitle = "문서 명을 입력해 주세요"
                showPopUp = true
                
            }, label: {
                Text("문서 추가")
                Image(systemName: "doc.badge.plus")
            })
            
            Button(action: {
                type = "GROUP"
                newGroupName = groupName
                lastText = newGroupName
                totalChars = lastText.count
                popUpMessage = "수정할 그룹 명을 입력해 주세요"
                AlertTitle = "그룹 명을 입력해 주세요"
                showPopUp = true
                
            }, label: {
                Text("그룹 이름 수정")
                Image(systemName: "square.and.pencil")
            })
            
            
            Button(action: {
                deleteAlert = true
            }, label: {
                Text("그룹 삭제")
                    .foregroundColor(.linkingRed)
                
                Image("trash")
                    .foregroundColor(.linkingRed)
            })
            
        } label: {
            
            Text("••• ")
                .font(.system(size: 12))
                .foregroundColor(.linkingLightGray)
                .padding(.trailing)
            
        }
        .buttonStyle(.borderless)
        .frame(width: 18.0)
    }
    
    func popUp() -> some View {
        VStack{
            HStack(alignment: .center){
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showPopUp = false
                    }
                    
                },label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .padding(.all)
                        .foregroundColor(Color.linkingGray)
                    
                }).padding(.all,5).buttonStyle(.borderless)
            }
            
            Text(popUpMessage)
                .font(.body)
                .foregroundColor(.linkingLightGray)
            
            if type == "PAGE" {
                PageTemplateView(selectedTemplates: $selectedTemplates)
            }
            
            TextField("", text: type == "PAGE" ? $pageTitle : $newGroupName)
                .textFieldStyle(.plain)
                .font(.body)
                .frame(width:200)
                .overlay(VStack{Divider().foregroundColor(.black).offset(x: 0, y: 20)})
                .padding(.all)
                .onSubmit {
                    if !nullCheck(text: type == "PAGE" ? pageTitle : newGroupName){
                        showAlert = true
                    }
                    else {
                        
                        type == "PAGE" ? groupVM.appendPage(title: pageTitle, index: index, template: selectedTemplates) : groupVM.updateGroup(index: index, name: newGroupName)
                        showPopUp = false
                    }
                }.onChange(of:type == "PAGE" ? pageTitle : newGroupName){
                    text in
                    totalChars = text.count
                    
                    if totalChars <= (type == "PAGE" ? 50 : 15) {
                            lastText = text
                    } else {
                        type == "PAGE" ? (pageTitle = lastText) : (newGroupName = lastText)
                    }
                }
            
            Text("\(totalChars) / \(type == "PAGE" ? 50 : 15)")
                .font(.footnote)
                .foregroundColor(.linkingLightGray)
                .frame(alignment: .trailing)
                .padding([.vertical])
            
            Button(action: {
                if !nullCheck(text: type == "PAGE" ? pageTitle : newGroupName){
                    showAlert = true
                }
                else {
                    
                    type == "PAGE" ? groupVM.appendPage(title: pageTitle, index: index, template: selectedTemplates) : groupVM.updateGroup(index: index, name: newGroupName)
                    showPopUp = false
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
struct SubListHeader_Previews: PreviewProvider {
    @State static var groupName: String = ""
    static var previews: some View {
        SubListHeader(index: 1, groupName: $groupName)
    }
}
