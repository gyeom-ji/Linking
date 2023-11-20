//
//  NotificationViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/17.
//

import Foundation
import SwiftyJSON

class NotificationViewModel: NSObject, ObservableObject {
    
    let urlString = Constants.baseURL
    let userId = UserDefaults.standard.integer(forKey: "userId")
    static let shared = NotificationViewModel()
    
    @Published var notificationList = [NotificationModel]()
    @Published var setting = SettingModel()
    @Published var notiBadgeCount = Int()
    
    var projectId = 0
    var webSocket = WebSocket()
    var isNotiOpened = false
    
    func insertFcmToken(token: String) {
        
        guard let url = URL(string: urlString + "/fcm-token/app") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "userId" : userId,
            "token" : token
        ] as [String : Any]
        print(body)
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: insertFcmToken error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertFcmToken HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: insertFcmToken JSON parsing failed")
                return
            }
            if decodedData.status == 200{
                
                DispatchQueue.main.async {
                    
                    print(decodedData.message)
                }
            }
            else {
                print("insertFcmToken failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
    func insertPagePushNotification(userId: Int, priority: Int, targetId: Int, content: String){
        let body = [
            "projectId" :  projectId,
            "userId" : userId,
            "sender" : UserDefaults.standard.string(forKey: "lastName")! + UserDefaults.standard.string(forKey: "firstName")!,
            "priority" : priority,
            "noticeType" :"PAGE",
            "targetId" : targetId,
            "body" : content
        ] as [String : Any]
        
        print(body)
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/push-notifications") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: insertPushNotification error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertPushNotification HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: insertPushNotification JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                
                print(decodedData.message)
            }
            else {
                print("insertPushNotification failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
    func insertTodoPushNotification(userId: Int, priority: Int, content: String){
        let body = [
            "projectId" :  projectId,
            "userId" : userId,
            "sender" : UserDefaults.standard.string(forKey: "lastName")! + UserDefaults.standard.string(forKey: "firstName")!,
            "priority" : priority,
            "noticeType" :"TODO",
            "body" : content
        ] as [String : Any]
        
        print(body)
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/push-notifications") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: insertPushNotification error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertPushNotification HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: insertPushNotification JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                
                print(decodedData.message)
            }
            else {
                print("insertPushNotification failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    func readNotificationList(){
        
        guard let url = URL(string: urlString + "/push-notifications/\(userId)") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: readNotificationList error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readNotificationList HTTP response failed")
                return
            }
            
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<[NotificationModel]>.self, from: data) else {
                print("Error: readNotificationList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.notificationList = decodedData.data!
                    print(self.notificationList)
                }
                print(decodedData.message)
            }
            
            else {
                print("readNotificationList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }
        dataTask.resume()
    }
    
    func readAppPushSettings(){
        
        guard let url = URL(string: urlString + "/push-settings/app/\(userId)") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: readAppPushSettings error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readAppPushSettings HTTP response failed")
                return
            }
            
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<SettingModel>.self, from: data) else {
                print("Error: readAppPushSettings JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.setting = decodedData.data!
                    print(self.setting)
                }
                print(decodedData.message)
            }
            
            else {
                print("readAppPushSettings failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }
        dataTask.resume()
    }
    
    func updateAppPushSettings(allowedWebAppPush: Bool, allowedMail: Bool){
        guard let url = URL(string: urlString+"/push-settings/app") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "userId" : userId,
            "allowedWebAppPush" : allowedWebAppPush,
            "allowedMail" : allowedMail
        ] as [String : Any]
        print(body)
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: updateAppPushSettings error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: updateAppPushSettings HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: updateAppPushSettings JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.setting.allowedMail = allowedMail
                    self.setting.allowedWebAppPush = allowedWebAppPush
                }
                print(decodedData.message)
            }
            else {
                print("updateAppPushSettings failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
}

/// WebSocket
extension NotificationViewModel {

    func connectNotiWebSocket(){
        webSocket.url = URL(string:  Constants.webSocketUrl + "/ws/push-notifications?userId=\(userId)")
        try? webSocket.openWebSocket()
        print("Noti Web Socket Connect")
        webSocket.delegate = self
        receiveMessage()
    }
    
    func openNotiWebSocket(){
        print("Noti Web Socket open")
        let body = [
            "isChecking": true
        ] as [String : Any]
        
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
    }
    
    func closeNotiWebSocket(){
        print("Noti Web Socket close")
        let body = [
            "isChecking" : false
        ] as [String : Any]
        
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
    }
    
    func disconnectWebSocket(){
        print("Noti Web Socket disconnect")
        let body = [
            "userId": userId
        ] as [String : Any]
    
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
        webSocket.closeWebSocket()
    }
    
    func receiveMessage() {

        if !webSocket.isOpened {
            try! webSocket.openWebSocket()
        }

        webSocket.webSocketTask?.receive(completionHandler: { [weak self] result in
            
            switch result {
            case .failure(let error):
                print("error")
                print(error.localizedDescription)
                self!.connectNotiWebSocket()
                
                if self!.isNotiOpened {
                    self!.openNotiWebSocket()
                }
                
            case .success(let message):
                switch message {
                case .string(let messageString):
                   
                    print("messageString")
                    print(messageString)

                    if let dict = try? JSONSerialization.jsonObject(with: Data(messageString.utf8), options: []) as? [String:Any]{
                        
                        if dict["resType"] as! String == "push"  {
                           
                            let jsonData = JSON(dict["data"]!)
                            
                            DispatchQueue.main.async {

                                self!.notificationList.insert(NotificationModel(projectId: jsonData["projectId"].intValue, body: jsonData["body"].stringValue, info: jsonData["info"].stringValue, priority: jsonData["priority"].intValue, noticeType: jsonData["noticeType"].stringValue, checked: jsonData["checked"].boolValue, targetId: jsonData["targetId"].intValue, assistantId: jsonData["assistantId"].intValue), at: 0)
                            }
                        }
                        else {
                           
                            DispatchQueue.main.async {
                                self?.notiBadgeCount = dict["data"] as! Int
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

extension NotificationViewModel: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("open")
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close")
    }
}
