//
//  LoginView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/22.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Binding var isLogin: Bool
    @Binding var showLogSignView: Bool
    @ObservedObject var userVM = UserViewModel()
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var AlertTitle: String  = ""
    
    var body: some View {
        VStack{
            Group{
                HStack{
                    
                    EmailPasswordTextFieldRow
                    
                    loginBtn
                }
                .padding(.vertical)
                
                HStack(alignment: .center) {
                    
                    appleLoginBtn
                    
                }
                .padding(.vertical)
                
                Text("- OR -")
                    .padding(.all, 20)
                    .font(.system(size: 18, weight: .regular))
                    .kerning(3)
                    .foregroundColor(Color.linkingGray)
                
                signUpBtn
            }
        }
    }
}

extension LoginView {
    
    var EmailPasswordTextFieldRow : some View {
        VStack(alignment: .trailing){
            InsertTextField(textValue: $userVM.user.email, headItem: "Email    ")
            InsertSecureTextField(textValue: $password, headItem: "Password")
                .onSubmit {
                    if !emailCheck(text: userVM.user.email) {
                        AlertTitle = "이메일 형식이 올바르지 않습니다."
                        showAlert = true
                    }
                    else if !nullCheck(text: password) {
                        AlertTitle = "비밀번호를 입력해 주세요."
                        showAlert = true
                    }
                    else {
                        userVM.insertUser(str: "/users/sign-in", parameters: [
                            "email" : userVM.user.email,
                            "password" : password
                        ]){
                            result in
                            if result == true {
                                withAnimation {
                                    showLogSignView = false
                                }
                            }
                            else {
                                AlertTitle = "일치하는 계정 정보가 없습니다."
                                showAlert = true
                            }
                        }
                    }
                }
        }
    }
    
    var appleLoginBtn: some View {
        SignInWithAppleButton(
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
                
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    print("Apple Login Successful")

                    if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                        let userId = appleIDCredential.user
                        let identityToken = appleIDCredential.identityToken
                        let authCode = appleIDCredential.authorizationCode
                        let email = appleIDCredential.email
                        let givenName = appleIDCredential.fullName?.givenName
                        let familyName = appleIDCredential.fullName?.familyName
                        print(email)
                        let state = appleIDCredential.state
                        // Here you have to send the data to the backend and according to the response let the user get into the app.
                    }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    print("error")
                }
            }
        )
        
    }
    
    var loginBtn: some View {
        Button(action: {
            if !emailCheck(text: userVM.user.email) {
                AlertTitle = "이메일 형식이 올바르지 않습니다."
                showAlert = true
            }
            else if !nullCheck(text: password) {
                AlertTitle = "비밀번호를 입력해 주세요."
                showAlert = true
            }
            else {
                userVM.insertUser(str: "/users/sign-in", parameters: [
                    "email" : userVM.user.email,
                    "password" : password
                ]){
                    result in
                    if result == true {
                        withAnimation {
                            showLogSignView = false
                        }
                    }
                    else {
                        AlertTitle = "일치하는 계정 정보가 없습니다."
                        showAlert = true
                    }
                }
            }
        }, label: {
            Text("로그인")
                .font(.title)
                .kerning(1)
                .frame(width: 100, height: 70)
                .padding()
                .foregroundColor(.white)
                .background(Color.buttonGray)
                .cornerRadius(10)
            
        }).padding(.horizontal, 50.0).buttonStyle(.borderless).alert(isPresented: $showAlert, content: {
            Alert(title: Text(AlertTitle))
        })
    }
    
    var signUpBtn: some View {
        Button(action: {
            withAnimation {
                isLogin = false
            }
        }, label: {
            Text("일반 회원 회원가입")
                .frame(width: 150.0)
                .kerning(1)
                .padding()
                .foregroundColor(.white)
                .background(Color.buttonGray)
                .cornerRadius(10)
        }).padding(.all).buttonStyle(.borderless)
    }
    
    func emailCheck(text: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
    
    func nullCheck(text: String) -> Bool {
        return text == "" ? false : true
    }
}
struct LoginView_Previews: PreviewProvider {
    @State static var isLogin: Bool = true
    @State static var showLogSignView: Bool = true
    
    static var previews: some View {
        
        LoginView(isLogin: $isLogin, showLogSignView: $showLogSignView)
    }
}
