//
//  ChatView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/27.
//

import SwiftUI

struct ChatView: View {
    @Binding var showChatView: Bool
    @EnvironmentObject var chatVM: ChatViewModel
    @State private var message: String = ""
    @State private var showPersonList: Bool = false
    @State private var page = 0
    let emptyScrollToString = "Empty"
    @State private var isFirst: Bool = true
    
    var body: some View {
        
        VStack{
            
            //closeBtn
            
            chatHeader
            
            Divider()
            
            chatBody
            
            chatFooter
            
        }.background(Color.lightBeige)
    }
}

extension ChatView {
//    var closeBtn: some View {
//        HStack(alignment: .center){
//            Spacer()
//
//            Button(action: {
//                showChatView = false
//            },
//                   label: {
//                Image(systemName: "xmark")
//                    .font(.body)
//                    .foregroundColor(Color.linkingGray)
//
//            }).buttonStyle(.borderless)
//        }.padding([.top, .leading, .trailing])
//    }
    
    var chatHeader: some View {
        HStack{
            Button(action: {
                showPersonList.toggle()
            }, label: {
                HStack{
                    Image(systemName: "person.fill")
                    Text("\(chatVM.chatPersonList.count)")
                }
            })
            .buttonStyle(.borderless) .popover(isPresented: $showPersonList,attachmentAnchor: .point(.leading), arrowEdge: .leading, content:{
                personListPopOverContents()
                    .background(Color.white)
            } ).help("View Participating Members")
            
            Spacer()
            
            Text("CHAT")
                .foregroundColor(.linkingGray)
                .font(.headline)
            
            Spacer()
        }
        .padding([.horizontal, .bottom],5)
    }
    
    func personListPopOverContents() -> some View {
        
        VStack(alignment: .leading){
            ForEach(0..<chatVM.chatPersonList.count, id: \.self){
                index in
                HStack{

                    Image(systemName: "person.wave.2.fill")
                        .foregroundColor(.linkingLightGray)
                        .padding(.trailing, 5)
                    Text(chatVM.chatPersonList[index])
                        .foregroundColor(.linkingLightGray)                        .padding([.vertical, .trailing], 5.0)
                        .kerning(1)
                    
                    Spacer()
                    
                }
            }
        }.frame(minWidth: 100)
            .padding(.all)
    }
    
    var chatBody: some View {
        
        ScrollView {
            ScrollViewReader {
                proxy in
                
                VStack{
                    LazyVStack{
                        ForEach(0..<chatVM.chatList.count, id:\.self) {
                            index in
                            chatRow(index: Int(index))
                                .onAppear(perform: {
                                    
                                    if Int(index) == 0 && !isFirst {
                                        page += 1
                                        chatVM.readChatList(page: page)
                                    }
                                    else if Int(index) == 0 && isFirst {
                                        isFirst = false
                                    }
                                    print(index)
                                }).id(index)
                            Divider()
                        }
                    }
                    HStack{Spacer()}
                        .id(emptyScrollToString)
                }.onAppear(perform: {
                    withAnimation(.easeOut(duration: 0.2)){
                        proxy.scrollTo(emptyScrollToString, anchor: .bottom)
                    }
                })
                .onReceive(chatVM.$addCount, perform: {
                    _ in
                    withAnimation(.easeOut(duration: 0.2)){
                        proxy.scrollTo(10)
                    }
                })
                .onReceive(chatVM.$newCount, perform: {
                    _ in
                    withAnimation(.easeOut(duration: 0.2)){
                        proxy.scrollTo(emptyScrollToString, anchor: .bottom)
                    }
                })
                
            }
        }
    }
    
    func chatRow(index: Int)-> some View {
        
        HStack{
            VStack{
                Text(chatVM.chatList[index].firstName)
                    .foregroundColor(.black)
                    .font(.body)
                    .padding(.all)
                    .background(
                        Circle()
                            .fill(Color.linkingYellow)
                    )
                
                Spacer()
                
            }.padding(.trailing, 5)
            
            VStack(alignment: .leading){
                Text(chatVM.chatList[index].userName)
                    .font(.callout)
                    .foregroundColor(.linkingLightGray)
                    .multilineTextAlignment(.leading)
                    .padding([.bottom, .trailing], 5.0)
                    .kerning(1)
                
                Text(chatVM.chatList[index].content)
                    .foregroundColor(.black)
                    .font(.body)
                    .padding(.bottom)
                    .lineLimit(.none)
                
                HStack{
                    Spacer()
                    
                    Text(chatVM.chatList[index].sentDatetime)
                        .font(.callout)
                        .foregroundColor(.linkingLightGray)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 5.0)
                }
            }
            
        }.padding(.all, 10)
    }
    
    func chatRow(firstName: String, userName: String, content: String, sentDatetime: String)-> some View {

        HStack{
            VStack{
                Text(firstName)
                    .foregroundColor(.black)
                    .font(.body)
                    .padding(.all)
                    .background(
                        Circle()
                            .fill(Color.linkingYellow)
                    )

                Spacer()

            }.padding(.trailing, 5)

            VStack(alignment: .leading){
                Text(userName)
                    .font(.callout)
                    .foregroundColor(.linkingLightGray)
                    .multilineTextAlignment(.leading)
                    .padding([.bottom, .trailing], 5.0)
                    .kerning(1)

                Text(content)
                    .foregroundColor(.black)
                    .font(.body)
                    .padding(.bottom)
                    .lineLimit(.none)

                HStack{
                    Spacer()

                    Text(sentDatetime)
                        .font(.callout)
                        .foregroundColor(.linkingLightGray)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 5.0)
                }
            }

        }.padding(.all, 10)
    }
    var chatFooter: some View {
        HStack{
            Spacer()
            TextField("Send message", text: $message, axis: .vertical)
                .padding(.all, 10.0)
                .lineLimit(1...)
                .lineSpacing(5)
                .font(.body)
                .background(Color.white)
                .textFieldStyle(.plain)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.linkingGray, lineWidth: 1)
                ).onSubmit {
                    chatVM.sendMessage(content: message)
                    message = ""
                }
            Spacer()
            Button(action: {
                chatVM.sendMessage(content: message)
                message = ""
            }, label: {
                Image(systemName: "paperplane")
                    .font(.system(size: 20))
                    .foregroundColor(.linkingGray)
            }).padding(.leading).buttonStyle(.borderless)
            Spacer()
        }
        .padding(.all).padding(.bottom, 10)
    }
}

struct ChatView_Previews: PreviewProvider {
    @State static var value: Bool = true
    static var previews: some View {
        ChatView(showChatView: $value)
    }
}

