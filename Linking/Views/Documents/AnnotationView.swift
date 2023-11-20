//
//  AnnotationView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import SwiftUI

struct AnnotationView: View {
    @State private var isClickChevron: Bool = false
    @EnvironmentObject var pageVM : PageViewModel
    var blockIndex : Int
    @State private var deleteAlert: Bool = false
    @State private var newAnnotContent: String  = ""
    @State private var AlertTitle: String  = ""
    @State private var showAlert: Bool = false
    @State private var showPopUp: Bool = false
    let userId = UserDefaults.standard.integer(forKey: "userId")
    
    var body: some View {
        
        VStack{
            
            if pageVM.page.blockResList[blockIndex].annotationList.count > 0 {
                toggleBtn
            }
            if  pageVM.page.blockResList[blockIndex].annotationList.count > 1 && !isClickChevron {
                Text("\(pageVM.page.blockResList[blockIndex].annotationList.count)개 주석 전체보기")
                    .multilineTextAlignment(.leading)
                    .padding([.leading, .bottom, .trailing])
            }
            else {
                
                List {
                    ForEach(0..<pageVM.page.blockResList[blockIndex].annotationList.count , id:\.self){
                        annotationIndex in
                        
                        if annotationIndex != 0 {
                            Divider()
                        }
                        
                        /// only the user who created Annotation can Delete/Update
                        if pageVM.page.blockResList[blockIndex].annotationList[annotationIndex].userId == userId {
                            annotationHeader(annotIndex: Int(annotationIndex))
                        }
                        
                        else {
                            Text(pageVM.page.blockResList[blockIndex].annotationList[annotationIndex].content)
                                .lineLimit(2...)
                                .font(.body)
                                .padding(.horizontal)
                        }
                        
                        nameDateFooter(name: pageVM.page.blockResList[blockIndex].annotationList[annotationIndex].userName, dateString: pageVM.getAnnotDateToString(blockIndex: blockIndex, annotIndex: Int(annotationIndex)))
                    }
                }
                
            }
        }.frame(maxWidth: 220).frame(minHeight: 60).overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.lightPeach, lineWidth: 4))
        .padding(.all)
    }
}

struct AnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationView(blockIndex: 1)
    }
}



extension AnnotationView {
    func nameDateFooter(name: String, dateString: String) -> some View {
        HStack{
            Spacer()
            Text(name + " " + dateString)
                .foregroundColor(.linkingLightGray)
                .font(.caption)
                .padding([.top, .bottom, .trailing], 10.0)
        }
    }
    
    var toggleBtn: some View {
        HStack{
            Spacer()
            Button(action: {
                isClickChevron.toggle()
            }, label: {
                Image(systemName: isClickChevron ? "chevron.up" : "chevron.down")
                    .foregroundColor(.linkingLightGray)
            }).padding([.top, .trailing], 10.0).buttonStyle(.borderless)
        }
        .padding(.bottom, -5)
    }
    
    func annotationHeader(annotIndex: Int) -> some View {
        ZStack{
            VStack{
                HStack{
                    Spacer()
                    
                    Menu {
                        
                        Button(action: {
                            newAnnotContent = pageVM.page.blockResList[blockIndex].annotationList[annotIndex].content
                            showPopUp = true
                        }, label: {
                            Image(systemName: "square.and.pencil")
                            Text("주석 수정")
                        })
                        
                        Button(action: {
                            deleteAlert = true
                        }, label: {
                            Image("trash")
                            Text("주석 삭제")
                                .foregroundColor(.linkingRed)
                        })
                        
                    } label: {
                        
                        Text("••• ")
                            .font(.system(size: 10))
                            .foregroundColor(.linkingLightGray)
                            .padding(.trailing)
                        
                    }
                    .padding(.trailing)
                    .buttonStyle(.borderless)
                    
                }
                Text(pageVM.page.blockResList[blockIndex].annotationList[annotIndex].content)
                    .lineLimit(2...)
                    .font(.body)
                    .padding(.horizontal)
            }
        }.popover(isPresented: $showPopUp, arrowEdge: .leading, content: {
            popUp(annotIndex: annotIndex).background(Color.white)
        }).alert("주석을 삭제하시겠습니까?", isPresented: $deleteAlert) {
            
            Button("Delete", role: .destructive) {
                pageVM.removeAnnotation(blockIndex: blockIndex, annotIndex: annotIndex)
            }
            
        }
    }
    
    func popUp(annotIndex: Int) -> some View {
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
            Text("수정할 주석 내용을 입력해 주세요")
                .font(.body)
                .foregroundColor(.linkingLightGray)
                .padding(.bottom, 10)
            
            TextField("", text:  $newAnnotContent)
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
                    if !nullCheck(text: newAnnotContent){
                        AlertTitle = "주석 내용을 입력해 주세요"
                        showAlert = true
                    }
                    else {
                        pageVM.updateAnnotation(blockIndex: blockIndex, annotIndex: annotIndex, content: newAnnotContent)
                        showPopUp = false
                    }
                }
            
            Button(action: {
                if !nullCheck(text: pageVM.page.blockResList[blockIndex].annotationList[annotIndex].content){
                    AlertTitle = "주석 내용을 입력해 주세요"
                    showAlert = true
                }
                else {
                    pageVM.updateAnnotation(blockIndex: blockIndex, annotIndex: annotIndex, content: newAnnotContent)
                    showPopUp = false
                }
            }, label: {
                Text("수정")
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
    
    func nullCheck(text: String) -> Bool {
        return text == "" ? false : true
    }
}
