//
//  PageTemplateView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/04/20.
//

import SwiftUI

struct PageTemplateView: View {
    @Binding var selectedTemplates: String
    
    var body: some View {
        VStack{
            HStack{
                
                blankTemplateBtn
                
                Spacer()
                    .frame(width: 40)
                
                blockTemplateBtn
            }
        }
        .padding(.all)
        .frame(width: 350)
    }
}

extension PageTemplateView {
    var blockTemplateBtn: some View {
        Button(action: {
            selectedTemplates = "BLOCK"
        }, label: {
            
            VStack{
                VStack{
                    
                    Spacer()
                    Text("Title")
                        .foregroundColor(.black)
                    
                    HStack{
                        Text("content")
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                            .padding([.top, .bottom, .trailing], 5)
                        
                        Image(systemName: "chevron.up")
                            .font(.system(size: 6))
                            .foregroundColor(.linkingLightGray)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 6))
                            .foregroundColor(.linkingLightGray)
                    }.frame(width: 85).overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.lightBorder, lineWidth: 2)
                    )
                    
                    Spacer()
                        .frame(height: 10)
                    
                    HStack{
                        
                        Text("body")
                            .font(.system(size: 9))
                            .foregroundColor(.black)
                            .padding([.top, .bottom, .trailing], 5)
                            .padding(.leading,10)
                        Spacer()
                    }.frame(width: 85).overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.lightBorder, lineWidth: 2)
                    )
                    
                    Spacer()
                    Spacer()
                    
                }.frame(width: 100, height: 100).background(.white).cornerRadius(10).overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedTemplates == "BLOCK" ? Color.linkingLightGreen : .lightBorder, lineWidth: 2)
                )
                Text("Content Page")
                    .foregroundColor(selectedTemplates == "BLOCK" ? .linkingLightGreen : .linkingLightGray)
            }.padding(.top).frame(width: 110, height: 150)
        }).frame(width: 110, height: 160).buttonStyle(.borderless)
    }
    
    var blankTemplateBtn: some View {
        Button(action: {
            selectedTemplates = "BLANK"
        }, label: {
            
            VStack{
                VStack{
                    
                    Text("Title")
                        .foregroundColor(.black)
                        .padding(.top, 5)
                    Spacer()
                    
                }.frame(width: 100, height: 100).background(.white).cornerRadius(10).overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedTemplates == "BLANK" ? Color.linkingLightGreen : .lightBorder, lineWidth: 2)
                )
                Text("Blank Page")
                    .foregroundColor(selectedTemplates == "BLANK" ? .linkingLightGreen : .linkingLightGray)
            }.padding(.top).frame(width: 110, height: 150)
            
        }).frame(width: 110, height: 150).buttonStyle(.borderless)
    }
}
struct PageTemplateView_Previews: PreviewProvider {
    @State static var selectedTemplates : String = "BLOCK"
    static var previews: some View {
        PageTemplateView(selectedTemplates: $selectedTemplates)
    }
}
