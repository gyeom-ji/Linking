//
//  BlankDocumentView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/04/23.
//

import SwiftUI

struct BlankDocumentView: View {
    enum FocusField: Hashable {
        case editor
    }
    @EnvironmentObject var pageVM : PageViewModel
    @EnvironmentObject var projectVM: ProjectViewModel
    @State private var oldValue: String = ""
    @FocusState private var focusedField: FocusField?
   
    var body: some View {
        
        HStack{
            Spacer()
                .frame(width: 50)
            
            TextEditor(text: $pageVM.blankPage.content)
                .lineLimit(1...)
                .scrollIndicators(.never)
                .font(.system(size: 20))
                .lineSpacing(5)
                .padding(.all, 20)
                .onChange(of: pageVM.blankPage.content){ new in
                    pageVM.sendBlankPageContent()
                }
                .focused($focusedField, equals: .editor)
            Spacer()
                .frame(width: 50)
        }
        .padding(.all).onAppear(perform: {
            focusedField = .editor
        })
    }
}
struct BlankDocumentView_Previews: PreviewProvider {
    
    static var previews: some View {
        BlankDocumentView()
    }
}
