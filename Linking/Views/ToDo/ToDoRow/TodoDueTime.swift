//
//  TodoStatusBtn.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/06.
//

import SwiftUI

struct TodoDueTime: View {
    var status: ToDoStatus
    var dueTime: String
    var body: some View {
        HStack{
            Image(systemName: "clock")
                .padding(.leading)
                .font(.footnote)
                .foregroundColor(status == .incomplete || status == .incompleteProgress ? .linkingRed : .linkingGreen)
            
            Text(dueTime)
                .font(.footnote)
                .padding(.leading, -3.0)
                .kerning(1)
                .foregroundColor(status == .incomplete || status == .incompleteProgress ? .linkingRed : .linkingGreen)
        }.frame(alignment: .leading)
    }
}

struct TodoDueTime_Previews: PreviewProvider {
    static var previews: some View {
        TodoDueTime(status: .basic, dueTime: "12:00 AM")
    }
}
