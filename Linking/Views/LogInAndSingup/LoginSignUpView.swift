//
//  LoginSignUpView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/14.
//

import SwiftUI

struct LoginSignUpView: View {
    @State private var isLogin: Bool = true
    @Binding var showLogSignView: Bool

    var body: some View {


            VStack{
                
                Spacer()
                
                LinkingLogo()
                    .padding(.vertical)
                
                Text(isLogin ? "LogIn" : "SignUp")
                    .padding(.all, 20.0)
                    .font(.system(size: 40, weight: .regular))
                    .kerning(3)
                    .foregroundColor(Color.linkingGray)
                
                Spacer()
                
                Group {
                    if isLogin {
                        LoginView(isLogin: $isLogin, showLogSignView: $showLogSignView)
                    }
                    else {
                        SignUpView(isLogin: $isLogin, showLogSignView: $showLogSignView)
                    }
                }
                Spacer()
            }
        }
}

struct LoginSignUpView_Previews: PreviewProvider {
    @State static var value: Bool = true
    static var previews: some View {
        Preview(source:  LoginSignUpView(showLogSignView: $value))
       
    }
}
