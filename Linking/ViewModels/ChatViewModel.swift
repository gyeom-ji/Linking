//
//  ChatViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/23.
//

import Foundation
import SwiftyJSON

class ChatViewModel: NSObject, ObservableObject {
    let urlString = Constants.webSocketUrl
    let userId = UserDefaults.standard.integer(forKey: "userId")
    var projectId = 0
    var webSocket = WebSocket()
    var isChatOpened = false
    
    @Published var chat = ChatModel()
    @Published var chatPersonList = [String]()
    @Published var chatList = [ChatModel]()
    @Published var newCount = Int()
    @Published var addCount = Int()
    @Published var chatBadgeCount = Int()
    
    let dateformat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.dateFormat = "yyyy. MM. dd. a h:m:s"
        return formatter
    }()
    
    func readChatList(page: Int){
        guard let url = URL(string: Constants.baseURL + "/chatroom/\(projectId)/chat-list?size=10&page=\(page)") else {
            print("Invalid URL")
            return
        }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: readChatList error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readChatList HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[ChatModel]>.self, from: data) else {
                print("Error: readChatList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    
                    self.chatList.insert(contentsOf: decodedData.data!.reversed(), at: 0)
                    print(self.chatList.count)
                    for i in 0..<self.chatList.count {
                        print("index: \(i)  == \(self.chatList[i])")
                    }
                    
                    if self.addCount != self.chatList.count  {
                        self.addCount = self.chatList.count
                    }
                }
            }
            else {
                print("readChatList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
        }
        dataTask.resume()
    }
    
    func readChatList(){
        guard let url = URL(string: Constants.baseURL + "/chatroom/\(projectId)/chat-list?size=10&page=0") else {
            print("Invalid URL")
            return
        }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: readChatList error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readChatList HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[ChatModel]>.self, from: data) else {
                print("Error: readChatList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    
                    self.chatList = decodedData.data!.reversed()
                    for i in 0..<self.chatList.count {
                        print("index: \(i)  == \(self.chatList[i])")
                    }
                    self.newCount += 1
                }
            }
            else {
                print("readChatList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
        }
        dataTask.resume()
    }
    
}

/// WebSocket
extension ChatViewModel {
    
    func connectChatWebSocket(){
        webSocket.url = URL(string:  Constants.webSocketUrl + "/ws/chatting")
        try? webSocket.openWebSocket()
        print("Chat Web Socket Connect")
        webSocket.delegate = self
        registeerChatWebSocket()
        receiveMessage()
    }
    
    func registeerChatWebSocket(){
        print("Chat Web Socket Register")
        let body = [
            "userId": "\(userId)",
            "projectId": "\(projectId)",
            "content": "",
            "sentDatetime": getDateToString(),
            "reqType": "register",
            "isFocusing": "false"
        ] as [String : String]
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
    }
    
    func unRegisterChatWebSocket(){
        
        print("Chat Web Socket unRegister")
        
        let body = [
            "userId": "\(userId)",
            "projectId": "\(projectId)",
            "content": "",
            "sentDatetime": getDateToString(),
            "reqType": "unregister",
            "isFocusing": "false"
        ] as [String : String]
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
        
        receiveMessage()
    }
    
    
    func openChatWebSocket(){
        
        print("Chat Web Socket Open")
        let body = [
            "userId": userId,
            "projectId": projectId,
            "content": "",
            "sentDatetime": getDateToString(),
            "reqType": "open",
            "isFocusing": false
        ] as [String : Any]
        
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
        
    }
    
    func sendMessage(content: String){
        let body = [
            "userId": userId,
            "projectId": projectId,
            "content": content,
            "sentDatetime": getDateToString(),
            "reqType": "text",
            "isFocusing": true
        ] as [String : Any]
        
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
    }
    
    func closeChatWebSocket(){
        print("Chat Web Socket close")
        let body = [
            "userId": userId,
            "projectId": projectId,
            "content": "",
            "sentDatetime": getDateToString(),
            "reqType": "close",
            "isFocusing": false
        ] as [String : Any]
        
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
        
        print("Chat Web Socket Close")
    }
    
    func disconnectWebSocket(){
        print("Chat Web Socket disconnect")
        let body = [
            "userId": userId,
            "projectId": projectId,
            "content": "",
            "sentDatetime": getDateToString(),
            "reqType": "disconnect",
            "isFocusing": false
        ] as [String : Any]
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
        webSocket.closeWebSocket()
        print("Chat Web Socket Disconnect")
    }
    
    func getDateToString()-> String {
        return dateformat.string(from: Date())
    }
    
}

//WebSocket
extension ChatViewModel {

    func receiveMessage() {
        
        if !webSocket.isOpened {
            try! webSocket.openWebSocket()
        }
        
        webSocket.webSocketTask?.receive(completionHandler: { [weak self] result in
            
            switch result {
            case .failure(let error):
                print("error")
                print(error.localizedDescription)
                self!.connectChatWebSocket()
                
                if self!.isChatOpened {
                    self!.openChatWebSocket()
                }
                
            case .success(let message):
                switch message {
                case .string(let messageString):
                    
                    print("messageString")
                    print(messageString)
                    
                    if let dict = try? JSONSerialization.jsonObject(with: Data(messageString.utf8), options: []) as? [String:Any]{
                        if dict["resType"] as! String == "userList"  {
                            
                            let jsonData = JSON(dict["data"]!)
                            
                            DispatchQueue.main.async {
                                self?.chatPersonList.removeAll()
                                if let siArray = jsonData.array {
                                    
                                    for i in 0..<siArray.count {
                                        
                                        self?.chatPersonList.append( siArray[i]["userName"].stringValue)
                                        
                                        print("\(i)  \(self!.chatPersonList[i])")
                                    }
                                }
                            }
                        }
                        
                        else if dict["resType"] as! String == "textMessage" {
                            let jsonData = JSON(dict["data"]!)
                            
                            DispatchQueue.main.async {
                                self?.chat = ChatModel(firstName: jsonData["firstName"].stringValue, userName: jsonData["userName"].stringValue, content: jsonData["content"].stringValue, sentDatetime: jsonData["sentDatetime"].stringValue)
                                
                                self?.chatList.append(ChatModel(firstName: jsonData["firstName"].stringValue, userName: jsonData["userName"].stringValue, content: jsonData["content"].stringValue, sentDatetime: jsonData["sentDatetime"].stringValue))
                                self?.newCount += 1
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self?.chatBadgeCount = dict["data"] as! Int
                            }
                        }
                        
                    }
                case .data(let data):
                    print("data")
                    print(data)
                    
                default:
                    print("Unknown type received from WebSocket")
                }
            }
            self?.receiveMessage()
        })
    }
}

extension ChatViewModel: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("open")
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close")
    }
}

