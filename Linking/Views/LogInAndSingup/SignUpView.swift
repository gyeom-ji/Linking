//
//  SignUpView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/22.
//

import SwiftUI

struct SignUpView: View {
    @Binding var isLogin: Bool
    @Binding var showLogSignView: Bool
    @ObservedObject var userVM = UserViewModel()
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var AlertTitle: String  = ""
    @State private var isCheckEmail: Bool = false
    
    var body: some View {
        
        VStack{
            HStack{
                
                inputTextFieldRow
                
                emailCheckBtn
            }
            
            signUpBtn
            
            showLoginViewBtn
        }
    }
}

extension SignUpView {
    var inputTextFieldRow: some View {
        VStack(alignment: .trailing){
            
            InsertTextField(textValue: $userVM.user.email, headItem: "Email    ")
            InsertTextField(textValue: $userVM.user.firstName, headItem: "FirstName")
            InsertTextField(textValue: $userVM.user.lastName, headItem: "LastName")
            InsertSecureTextField(textValue: $password, headItem: "Password")
                .onSubmit {
                    if !emailCheck(text: userVM.user.email) {
                        AlertTitle = "이메일 형식이 올바르지 않습니다."
                        showAlert = true
                    }
                    else if !nullCheck(text: password){
                        AlertTitle = "비밀번호를 입력해 주세요."
                        showAlert = true
                    }
                    else if !nullCheck(text: userVM.user.firstName){
                        AlertTitle = "이름을 입력해 주세요."
                        showAlert = true
                    }
                    else if !nullCheck(text: userVM.user.lastName){
                        AlertTitle = "성을 입력해 주세요."
                        showAlert = true
                    }
                    
                    else if !isCheckEmail{
                        AlertTitle = "이메일 중복 확인을 해주세요."
                        showAlert = true
                    }
                    
                    else {
                        userVM.insertUser(str: "/users/sign-up", parameters: [
                            "lastName" :  userVM.user.lastName,
                            "firstName" : userVM.user.firstName,
                            "email" : userVM.user.email,
                            "password" : password
                        ]) {
                            result in
                            if result == true {
                                withAnimation {
                                    showLogSignView = false
                                }
                            }
                            else {
                                AlertTitle = "계정 생성에 실패했습니다. 다시 시도해주세요."
                                showAlert = true
                            }
                        }
                        
                    }
                }
        }
        .padding(.vertical)
    }
    
    var emailCheckBtn: some View {
        VStack{
            Button(action: {
                if !emailCheck(text: userVM.user.email) {
                    AlertTitle = "이메일 형식이 올바르지 않습니다."
                    showAlert = true
                }
                else {
                    userVM.checkEmail(str: "/users/verify/email", paramerers: ["email" : userVM.user.email])
                    if userVM.isEmailCheck {
                        isCheckEmail = true
                        AlertTitle = "사용 가능한 이메일 입니다."
                        showAlert = true
                    }
                    else if userVM.isEmailCheck == false {
                        AlertTitle = "등록된 이메일 입니다. 다시 시도해 주세요"
                        showAlert = true
                    }
                }
                
            }, label: {
                Text("중복 확인")
                    .font(.body)
                    .frame(width: 60.0, height: 5.0)
                    .kerning(1)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.buttonGray)
                    .cornerRadius(10)
                
            }).buttonStyle(.borderless).alert(isPresented: $showAlert, content: {
                Alert(title: Text(AlertTitle))
            })
            
            Spacer()
                .frame(height:250)
        }
        .padding(.vertical)
    }
    
    var signUpBtn: some View {
        Button(action: {
            
            if !emailCheck(text: userVM.user.email) {
                AlertTitle = "이메일 형식이 올바르지 않습니다."
                showAlert = true
            }
            else if !nullCheck(text: password){
                AlertTitle = "비밀번호를 입력해 주세요."
                showAlert = true
            }
            else if !nullCheck(text: userVM.user.firstName){
                AlertTitle = "이름을 입력해 주세요."
                showAlert = true
            }
            else if !nullCheck(text: userVM.user.lastName){
                AlertTitle = "성을 입력해 주세요."
                showAlert = true
            }
            
            else if !isCheckEmail{
                AlertTitle = "이메일 중복 확인을 해주세요."
                showAlert = true
            }
            
            else {
                userVM.insertUser(str: "/users/sign-up", parameters: [
                    "lastName" :  userVM.user.lastName,
                    "firstName" : userVM.user.firstName,
                    "email" : userVM.user.email,
                    "password" : password
                ]) {
                    result in
                    if result == true {
                        withAnimation {
                            showLogSignView = false
                        }
                    }
                    else {
                        AlertTitle = "계정 생성에 실패했습니다. 다시 시도해주세요."
                        showAlert = true
                    }
                }
                
            }
        }, label: {
            Text("회원가입")
                .font(.title)
                .frame(width: 150.0)
                .kerning(1)
                .padding()
                .foregroundColor(.white)
                .background(Color.buttonGray)
                .cornerRadius(10)
        }).padding(.all).buttonStyle(.borderless).alert(isPresented: $showAlert, content: {
            Alert(title: Text(AlertTitle))
        })
    }
    
    var showLoginViewBtn: some View {
        HStack{
            Text("이미 Linking 계정이 있으신가요? ")
                .font(.body)
                .kerning(1)
                .foregroundColor(Color.linkingGray)
            
            Button(action: {
                withAnimation {
                    isLogin = true
                }
                
            }, label: {
                Text("LogIn")
                    .font(.body)
                    .fontWeight(.regular)
                    .kerning(2)
                    .foregroundColor(Color.orange)
            }).padding(.all).buttonStyle(.borderless)
        }
    }
    
    
    func emailCheck(text: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailTest.evaluate(with: text)
    }
    
    func nullCheck(text: String) -> Bool {
        return text == "" ? false : true
    }
}

struct SignUpView_Previews: PreviewProvider {
    @State static var isLogin: Bool = true
    @State static var showLogSignView: Bool = true
    
    static var previews: some View {
        SignUpView(isLogin: $isLogin, showLogSignView: $showLogSignView)
    }
}
