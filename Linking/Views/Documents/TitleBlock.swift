//
//  TitleBlock.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import SwiftUI

struct TitleBlock: View {
    @Binding var showBodyTargetId: Int
    @Binding var isShowBody: Bool
    @EnvironmentObject var projectVM : ProjectViewModel
    @EnvironmentObject var groupVM : GroupViewModel
    @EnvironmentObject var pageVM : PageViewModel
    @State private var annotcontent: String = ""
    @State private var AlertTitle: String  = ""
    @State private var showAlert: Bool = false
    @State private var showAnotationPopUp: Bool = false
    @State private var showBlockCopyPopUp: Bool = false
    @State private var deleteAlert: Bool = false
    @State private var selectGroupId: Int = -1
    @State private var selectPageId: Int = -1
    var blockIndex: Int
    
    var body: some View{
        VStack{
            if pageVM.page.blockResList.count > blockIndex {
                HStack{

                    if pageVM.getAnnotListCount(blockIndex: blockIndex) > 0 {
                        annotationCountIcon
                    }
                    else {
                        VStack{
                            Spacer().frame(width: 38)
                        }
                    }
                    
                    VStack{
                        HStack{
                            Spacer()
 
                            VStack{
                                TextEditor(text: $pageVM.page.blockResList[blockIndex].title)
                                    .lineLimit(1...)
                                    .scrollIndicators(.never)
                                    .font(.system(size: 24))
                                    .lineSpacing(5)
                                    .onChange(of: pageVM.page.blockResList[blockIndex].title){ new in
                                        pageVM.sendBlockContent(editorType: 1, blockIndex: blockIndex)
                                        
                                    }
                            }
                            VStack{
                                
                                HStack{
                                    showBodyBlockBtn
                                    
                                    titleMenu
                                }.padding(.top, 10)
                                
                                Spacer()
                            }
                        }.padding(.all).frame(maxWidth: 1000).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.lightBorder, lineWidth: 2)
                        )}

                        Spacer()
                            .frame(width: 260)
                    
                }
            }
        }
    }
}

struct TitleBlock_Previews: PreviewProvider {
    @State static var isShowBody: Bool = true
    @State static var showBodyTargetId: Int = 0
    static var previews: some View {
        TitleBlock(showBodyTargetId: $showBodyTargetId, isShowBody: $isShowBody, blockIndex: 1).environmentObject(PageViewModel())
    }
}

extension TitleBlock{
    var titleMenu: some View{
        ZStack{
            Menu {
                
                Button(action: {
                    annotcontent = ""
                    showAnotationPopUp = true
                }, label: {
                    Image(systemName: "square.and.pencil")
                    Text("주석 추가")
                })
                
                Button(action: {
                    groupVM.readBlockPageList(projectId: projectVM.project.id)
                    showBlockCopyPopUp = true
                }, label: {
                    Image(systemName: "plus.square.on.square")
                    
                    Text("블록 복제")
                })
                
                Button(action: {
                    deleteAlert = true
                }, label: {
                    Image("trash")
                    
                    Text("블록 삭제")
                        .foregroundColor(.linkingRed)
                })
                
            } label: {
                
                Text("• • • ")
                    .foregroundColor(.linkingLightGray)
            }.buttonStyle(.borderless)
                .frame(width: 50.0)
        }.popover(isPresented: $showAnotationPopUp, arrowEdge: .leading, content: {
            annotationPopUp().background(Color.white)
            
        }).popover(isPresented: $showBlockCopyPopUp, arrowEdge: .leading, content: {
            blockCopyPopUp().background(Color.white)
            
        }).alert("블록에 포함된 주석도 함께 삭제 됩니다.", isPresented: $deleteAlert) {
            
            Button("Delete", role: .destructive) {
                //delete
                pageVM.removeBlock(blockIndex: blockIndex)
            }
            
        } message: {
            Text("삭제 하시겠습니까?")
        }
    }
    
    var annotationCountIcon: some View {
        VStack{
            
            Text("\(pageVM.page.blockResList[blockIndex].annotationList.count)")
                .foregroundColor(.white)
                .font(.footnote)
                .fontWeight(.medium)
                .padding()
                .background(
                    Circle()
                        .foregroundColor(.peach)
                        .padding(12)
                )
            if isShowBody {
                Spacer()
            }
        }
    }
    
    var showBodyBlockBtn: some View {
        Button(action: {
            showBodyTargetId = blockIndex
            isShowBody.toggle()
        }, label: {
            VStack{
                Image(systemName: isShowBody ? "chevron.up" : "chevron.down")
                    .font(.system(size: 15))
            }.foregroundColor(.linkingLightGray)
        }).padding(.trailing).buttonStyle(.borderless)
    }
    
    func annotationPopUp() -> some View {
        VStack{
            HStack(alignment: .center){
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showAnotationPopUp = false
                    }
                    
                },
                       label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .padding(.all)
                        .foregroundColor(Color.linkingGray)
                    
                }).padding(.all,5).buttonStyle(.borderless)
            }
            
            Text("추가할 주석 내용을 입력해 주세요")
                .font(.body)
                .foregroundColor(.linkingLightGray)
                .padding(.bottom, 10)
            
            TextField("", text:  $annotcontent)
                .padding(.all, 10.0)
                .frame(width:200)
                .lineLimit(1...)
                .lineSpacing(5)
                .font(.body)
                .background(Color.white)
                .textFieldStyle(.plain)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.linkingLightGray, lineWidth: 1)
                )
                .onSubmit {
                    if !nullCheck(text: annotcontent){
                        AlertTitle = "주석 내용을 입력해 주세요"
                        showAlert = true
                    }
                    else {
                        pageVM.appendAnnotation(content: annotcontent, blockIndex: blockIndex)
                        showAnotationPopUp = false
                    }
                }
            
            Button(action: {
                if !nullCheck(text: annotcontent){
                    AlertTitle = "주석 내용을 입력해 주세요"
                    showAlert = true
                }
                else {
                    pageVM.appendAnnotation(content: annotcontent, blockIndex: blockIndex)
                    showAnotationPopUp = false
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
            
        }.padding(.horizontal)
    }
    
    func blockCopyPopUp() -> some View {
        VStack{
            HStack(alignment: .center){
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showBlockCopyPopUp = false
                    }
                    
                },
                       label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .padding(.all)
                        .foregroundColor(Color.linkingGray)
                    
                }).padding(.all,5).buttonStyle(.borderless)
            }
            
            Text("블록을 복제할 문서를 선택해 주세요")
                .font(.body)
                .foregroundColor(.linkingLightGray)
                .padding(.bottom, 20)
            
            ScrollView {
                ForEach(0..<groupVM.blockGroupList.count, id: \.self, content: {
                    index in
                    HStack{
                        Text(groupVM.blockGroupList[index].groupName)
                            .foregroundColor(.linkingGray)
                            .padding([.leading, .bottom], 5)
                            .kerning(1)
                        Spacer()
                    }
                    ForEach(0..<groupVM.blockGroupList[index].blockPageList.count, id: \.self, content: {
                        pageIndex in
                        Button(action: {
                            
                            if (selectGroupId != index && selectPageId != pageIndex) {
                                if selectGroupId != -1 {
                                    groupVM.blockGroupList[selectGroupId].blockPageList[selectPageId].isSelected = false
                                }
                            }
                            
                            groupVM.blockGroupList[index].blockPageList[pageIndex].isSelected.toggle()
                            selectPageId = pageIndex
                            selectGroupId = index
                            
                            print(selectPageId)
                            
                        }, label: {
                            HStack{
                                if groupVM.blockGroupList[index].blockPageList[pageIndex].isSelected {
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.linkingBlue)
                                        .padding(.top, 2.0)
                                }
                                else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.primary)
                                        .padding(.top, 2.0)
                                }
                                Text(groupVM.blockGroupList[index].blockPageList[pageIndex].pageTitle)
                                    .foregroundColor(.black)
                                    .kerning(1)
                                Spacer()
                                
                            }}).buttonStyle(BorderlessButtonStyle()).padding([.leading, .bottom, .trailing], 10)
                    })
                    
                })
            }.frame(width:150, height: 150)
            
            Button(action: {
                
                if selectGroupId == -1 {
                    AlertTitle = "블록을 복제할 문서를 선택해 주세요"
                    showAlert = true
                }
                else {
                    var cloneType = "OTHER"
                    if groupVM.blockGroupList[selectGroupId].groupId == pageVM.page.groupId {
                        
                        if groupVM.blockGroupList[selectGroupId].blockPageList[selectPageId].pageId == pageVM.page.id {
                            cloneType = "THIS"
                        }
                    }

                    pageVM.cloneBlock(cloneType: cloneType, blockIndex: blockIndex, pageId: groupVM.blockGroupList[selectGroupId].blockPageList[selectPageId].pageId)
                    
                    showBlockCopyPopUp = false
                }
                
            }, label: {
                Text("복제")
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
            
        }.padding(.horizontal).frame(width: 400)
    }
    
    func nullCheck(text: String) -> Bool {
        return text == "" ? false : true
    }
    
}
