//
//  ProjectUserRow.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/15.
//

import SwiftUI

struct ProjectUserRow: View {
    let user: User
    var body: some View {
        HStack(alignment: .center){
            Text(user.lastName+user.firstName)
                .font(.body)
            Spacer()
            Text(user.email)
                .font(.body)
        }
        .padding(.bottom)
    }
}

struct ProjectUserRow_Previews: PreviewProvider {
    static var previews: some View {
        ProjectUserRow(user: User(id: 0, firstName: "gyeomji", lastName: "yun", email: "ruawl12@icloud.com"))
    }
}
