//
//  SearchUserView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/15.
//

import SwiftUI

struct SearchUserView: View {
    @EnvironmentObject var project: ProjectViewModel
    @ObservedObject var userVM = UserViewModel()
    @State private var partOfEmail: String = ""
    @State private var selected = -1
    @State private var tag:Int? = nil
    @Binding var showSearchUserView: Bool
    @State private var tempUser = [User]()
    @State private var showAlert: Bool = false
    @State private var AlertTitle: String  = ""
    @Binding var isMemberUpdate : Bool
    var body: some View {
        
        VStack{
            
            closeBtn
            
            searchRow
            
            userScrollView
            
            insertBtn
            
            Spacer(minLength: 60)
            
        }.frame(width: 450, height: 420)
        
    }
}

extension SearchUserView{
    
    var closeBtn: some View {
        HStack(alignment: .center){
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    showSearchUserView = false
                }
            },
                   label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .padding(.all)
                    .foregroundColor(Color.linkingGray)
            }).padding(.top).buttonStyle(.borderless)
            
        }
        .padding([.top, .leading])
    }
    
    var searchRow: some View {
        HStack(alignment: .center){
            Spacer()
            
            searchTextField
            
            searchBtn
            
            Spacer()
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    func nullCheck(text: String) -> Bool {
        return text == "" ? false : true
    }
    
    var userScrollView : some View {
        ScrollView {
            HStack(alignment: .center){
                
                
                Picker("", selection: $selected) {
                    ForEach(0..<userVM.userList.count, id:\.self) { index in
                        ProjectUserRow(user: userVM.userList[index])
                            .tag(index)
                    }
                }
                .padding(.all)
                .frame(width: 400.0)
                .pickerStyle(.radioGroup)
                
            }
            
        }.background(Color.beige.opacity(0.3))
            .cornerRadius(10)
            .padding(.all)
            .frame(height: 150)
    }
    
    var insertBtn: some View {
        Button(action: {
            project.appendUser(newUser: userVM.userList[selected])
            withAnimation {
                showSearchUserView = false
            }
            
            isMemberUpdate = true
        }, label: {
            Text("팀원 추가")
                .font(.body)
                .kerning(1)
                .frame(width: 65)
                .padding(.all)
                .foregroundColor(Color.white)
                .background(Color.buttonGray)
                .cornerRadius(10)
            
        }).buttonStyle(.borderless).padding(.top)
    }
    
    var searchBtn: some View {
        Button(action: {
            if !nullCheck(text: partOfEmail) {
                AlertTitle = "이메일을 입력해 주세요."
                showAlert = true
            }
            else{
                userVM.readFindUserListByEmail(partOfEmail: partOfEmail, projectId: project.project.id)
            }
        },
               label: {
            Image(systemName: "magnifyingglass")
                .font(.title)
                .foregroundColor(Color.linkingGray)
                .padding(.all)
        }).padding(.trailing).buttonStyle(.borderless).alert(isPresented: $showAlert, content: {
            Alert(title: Text(AlertTitle))
            
        })
    }
    
    var searchTextField: some View {
        TextField("Search user email", text: $partOfEmail)
            .textFieldStyle(.plain)
            .font(.body)
            .frame(width: 300)
            .overlay(VStack{Divider().foregroundColor(.black).offset(x: 0, y: 15)})
            .padding(.leading)
            .onSubmit {
                if !nullCheck(text: partOfEmail) {
                    AlertTitle = "이메일을 입력해 주세요."
                    showAlert = true
                }
                else{
                    userVM.readFindUserListByEmail(partOfEmail: partOfEmail, projectId: project.project.id)
                }
            }.alert(isPresented: $showAlert, content: {
                Alert(title: Text(AlertTitle))
                
            })
    }
}
struct SearchUserView_Previews: PreviewProvider {
    @State static var value = true
    @State static var isMemberUpdate = true
    static var previews: some View {
        SearchUserView(userVM: UserViewModel(), showSearchUserView: $value, isMemberUpdate: $isMemberUpdate)
    }
}
