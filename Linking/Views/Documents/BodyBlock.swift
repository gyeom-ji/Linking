//
//  BodyBlock.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/25.
//

import SwiftUI

struct BodyBlock: View {
    @EnvironmentObject var pageVM : PageViewModel
    var blockIndex: Int
    
    var body: some View {
        if pageVM.page.blockResList.count > blockIndex {
            HStack{
            
            VStack{
                Spacer().frame(width: 38)
            }
            
            VStack{
                
                TextEditor(text: $pageVM.page.blockResList[blockIndex].content)
                    .lineLimit(1...)
                    .scrollIndicators(.never)
                    .font(.system(size: 20))
                    .lineSpacing(5)
                    .onChange(of: pageVM.page.blockResList[blockIndex].content){ new in
                        pageVM.sendBlockContent(editorType: 2, blockIndex: blockIndex)
                        
                    }
                //                TextField("", text: $pageVM.page.blockResList[blockIndex].content, axis: .vertical)
                //                    .lineLimit(1...)
                //                    .textFieldStyle(.plain)
                //                    .font(.system(size: 20))
                //                    .lineSpacing(5)
                //                    .frame(minHeight: 50)
                //                    .onChange(of: pageVM.page.blockResList[blockIndex].content){ new in
                //                        pageVM.sendBlockContent(editorType: 2, blockIndex: blockIndex)
                //                    }
                //                    .onSubmit {
                //                        pageVM.page.blockResList[blockIndex].content += "\n"
                //                    }
                
            }.padding(.all).frame(maxWidth: 1000).overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.lightBorder, lineWidth: 2)
            )
        }
        }
    }
}

struct BodyBlock_Previews: PreviewProvider {
   
    static var previews: some View {
        BodyBlock(blockIndex: 1)
    }
}
