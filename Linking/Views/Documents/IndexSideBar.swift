//
//  IndexSideBar.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/25.
//

import SwiftUI

struct IndexSideBar: View {
    @EnvironmentObject var pageVM : PageViewModel
    @State private var isEdit: Bool = false
    @State private var showPopUp: Bool = false
    @State private var newBlockTitle: String = ""
    @State private var AlertTitle: String  = ""
    @State private var showAlert: Bool = false
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack{
            
            sideBarHeader
            
            sideBarContent

            Spacer()

            sideBarFooter
            
        }.frame(minWidth: 200)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.lightBeige)
    }
}

extension IndexSideBar {
    var sideBarFooter: some View {
        HStack(alignment: .bottom){
            Spacer()
            Button(action: {
                isEdit.toggle()
                if !isEdit {
                    //send
                    pageVM.changeOrderBlock()
                }
            }, label: {
                if !isEdit{
                    Image(systemName: "arrow.up.and.down.text.horizontal")
                        .foregroundColor(.linkingGray)
                        .font(.system(size:17))
                }
                else {
                    Text("Done")
                        .foregroundColor(.linkingGray)
                        .font(.system(size:17))
                }
            }).padding(.trailing).buttonStyle(.borderless)
            
            Button(action: {
     
            }, label: {
                Image(systemName: "trash")
                    .foregroundColor(.linkingGray)
                    .font(.system(size:17))
            }).buttonStyle(.borderless)
        }.padding([.top, .bottom, .trailing]).background(Color.lightBeige)
    }
    
    var sideBarHeader: some View {
        
        Text("목차")
            .font(.system(size:20))
            .foregroundColor(.linkingLightGray)
            .padding(.top)
            .kerning(8)
        
    }
    
    var sideBarContent: some View {
        VStack(alignment: .leading){
            List {
                ForEach(0..<pageVM.page.blockResList.count, id:\.self, content: {
                    index in
                    if pageVM.page.blockResList[index].id != -1 {
                        HStack{
                            VStack{
                                Text("\(index + 1).")
                                    .font(.system(size:16))
                                    .foregroundColor(.linkingLightGray)
                                    .multilineTextAlignment(.leading)
                                    .padding(.top, 20)
                                    .kerning(2)
                                Spacer()
                            }
                            Text(pageVM.page.blockResList[index].title)
                                .font(.system(size:16))
                                .foregroundColor(.linkingLightGray)
                                .multilineTextAlignment(.leading)
                                .padding(.top)
                                .kerning(2)
                                .onTapGesture {
                                    pageVM.isSelected = true
                                    selectedIndex = index
                                }.help("Move to Block")
                            
                            Spacer()
                            
                            if isEdit {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size:20))
                                    .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                            }
                        }
                    }
                   
                }).onMove(perform: isEdit ? {
                    from, to in
                    pageVM.page.blockResList.move(fromOffsets: from, toOffset: to)
                } : nil)
                
                sideBarInsertBlockBtn
                    .moveDisabled(true)
                
            }.frame(minWidth: 200).listRowBackground(Color.clear)
        }.scrollContentBackground(.hidden)
    }
    
    var sideBarInsertBlockBtn: some View {

        HStack{
            Spacer()
            Button(action: {
                newBlockTitle = ""
                showPopUp = true
            }, label: {
                VStack{
                    Image(systemName: "plus.circle")
                        .padding(.bottom, 1.0)
                        .font(.title)
                        .fontWeight(.thin)
                    
                    Text("목차 추가")
                        .font(.body)
                        .fontWeight(.thin)
                        .kerning(1)
                }.foregroundColor(.linkingLightGray)
            }).buttonStyle(.borderless).popover(isPresented: $showPopUp, arrowEdge: .leading, content: {
                popUp().background(Color.white)
            })
            Spacer()
        }
        .padding([.top, .leading])
    }
    
    func popUp() -> some View {
        VStack{
            HStack(alignment: .center){
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showPopUp = false
                    }
                    
                },
                       label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .padding(.all)
                        .foregroundColor(Color.linkingGray)
                    
                }).padding(.all,5).buttonStyle(.borderless)
            }
            
            Text("추가할 목차(블록 제목)를 입력해 주세요")
                .font(.body)
                .foregroundColor(.linkingLightGray)
            
            
            TextField("", text:  $newBlockTitle)
                .textFieldStyle(.plain)
                .font(.body)
                .frame(width:200)
                .overlay(VStack{Divider().foregroundColor(.black).offset(x: 0, y: 20)})
                .padding(.all)
                .onSubmit {
                    if !nullCheck(text: newBlockTitle){
                        AlertTitle = "목차를 입력해 주세요"
                        showAlert = true
                    }
                    else {
                      //Insert Block
                        pageVM.appendBlock(blockTitle: newBlockTitle)
                        showPopUp = false
                    }
                }
            
            Button(action: {
                if !nullCheck(text: newBlockTitle){
                    AlertTitle = "목차를 입력해 주세요"
                    showAlert = true
                }
                else {
                    pageVM.appendBlock(blockTitle: newBlockTitle)
                    showPopUp = false
                }
            }, label: {
                Text("저장")
                    .font(.body)
                    .kerning(1)
                    .frame(width: 50.0)
                    .padding(.all, 10)
                    .foregroundColor(Color.linkingLightGray)
                    .background(Color.beige)
                    .cornerRadius(10)
            }).padding(.vertical).buttonStyle(.borderless).alert(isPresented: $showAlert, content: {
                Alert(title: Text(AlertTitle))
            })
            
        }
    }
    
    func nullCheck(text: String) -> Bool {
            return text == "" ? false : true
    }
}


struct IndexSideBar_Previews: PreviewProvider {
    @State static var selectedIndex : Int = 0
    static var previews: some View {
        IndexSideBar(selectedIndex: $selectedIndex)
    }
}
