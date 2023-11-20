//
//  LinkingLogo.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/15.
//

import SwiftUI

struct LinkingLogo: View {
    var body: some View {
        HStack(alignment: .center){
            Spacer()
            
            Image(systemName: "chevron.left").resizable()
                .foregroundColor(Color.linkingGray)
                .fontWeight(.thin)
                .frame(width: 35, height: 90)
            
            Image("chain").resizable()
                .frame(width: 80, height: 150)
                .scaledToFit()
                .padding(.horizontal, 30.0)
            
            Image(systemName: "chevron.right").resizable()
                .fontWeight(.thin)
                .foregroundColor(Color.linkingGray)
                .frame(width: 35, height: 90)
            
            Spacer()
        }
    }
}

struct LinkingLogo_Previews: PreviewProvider {
    static var previews: some View {
        LinkingLogo()
    }
}
