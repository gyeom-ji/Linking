//
//  CustomDatePicker.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/17.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var date: Date
    var viewMode : ViewMode
    var titleText: String
    var dateText: String
    var startDate: Date
    
    var body: some View{
        
        VStack(alignment: .leading) {
            Text(titleText)
                .kerning(1)
                .foregroundColor(Color.linkingLightGray)
                .padding(.leading)
            
            if viewMode == .read {
                Text(dateText)
                    .kerning(1)
                    .padding([.top, .leading])
            }
            else {
                if titleText == "마감일" {
                    DatePicker("", selection: $date, in: startDate..., displayedComponents: .date).cornerRadius(20).padding(.leading).datePickerStyle(.compact).frame(width: 150, height: 50)
                }
                else {
                    DatePicker("", selection: $date, displayedComponents: .date).cornerRadius(20).padding(.leading).datePickerStyle(.compact).frame(width: 150, height: 50)
                }
            }
        }
        .padding(.top)
    }
}

struct CustomDatePicker_Previews: PreviewProvider {
    @State static var date = Date()
    static var previews: some View {
        CustomDatePicker(date: $date, viewMode: .update, titleText: "시작일", dateText: "2023/03/12", startDate: Date())
    }
}
