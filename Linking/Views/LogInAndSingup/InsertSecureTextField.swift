//
//  InsertSecureTextField.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/22.
//

import SwiftUI

struct InsertSecureTextField: View {
    @State private var totalChars : Int = 0
    @State private var lastText : String = ""
    @Binding var textValue: String
    var headItem: String = ""
    
    var body: some View {
        VStack {
            HStack(alignment: .center){
                
                Text(headItem)
                    .font(.title)
                    .foregroundColor(Color.linkingGray)
                    .multilineTextAlignment(.trailing)
                    .padding([.top, .bottom, .trailing])
                
                SecureField("Enter Password (at least 4)", text: $textValue)
                    .textFieldStyle(.plain)
                    .font(.title)
                    .frame(width: 300)
                    .overlay(VStack{Divider().offset(x: 0, y: 15)})
                    .padding(.all)
                    .onChange(of: textValue){
                        text in
                        totalChars = text.count
                        
                        if totalChars <= 20 {
                            lastText = text
                        } else {
                            textValue = lastText
                        }
                    }
                
            }
            HStack(alignment: .center){
                Spacer().frame(width: 400)
                Text("\(totalChars) / 20")
                    .font(.footnote)
                    .foregroundColor(.linkingLightGray)
                    .frame(alignment: .trailing)
                    
            }.padding(.top, -15)
        }
    }
}

struct InsertSecureTextField_Previews: PreviewProvider {
    @State static var value: String = "test"
    static var previews: some View {
        InsertSecureTextField(textValue: $value)
    }
}
