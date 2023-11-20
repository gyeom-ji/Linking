//
//  PageViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/25.
//

import Foundation
import IKEventSource
import SwiftyJSON

class PageViewModel: NSObject, ObservableObject {
    let urlString = Constants.baseURL
    let projectId = UserDefaults.standard.integer(forKey: "projectId")
    let userId = UserDefaults.standard.integer(forKey: "userId")
    var eventSource: EventSource?
    var blockVM = BlockViewModel()
    var webSocket = WebSocket()
    var annotationVM = AnnotationViewModel()
    
    @Published var page = Page()
    @Published var blankPage = BlankPage()
    @Published var pageList = [Page]()
    @Published var isNewPage : Int = 0
    @Published var isSelected = Bool()
    
    let dateformat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.dateFormat = "yy-MM-dd a HH:mm"
        return formatter
    }()
    
    func insertPage(groupId: Int, order: Int, title: String, template: String, completion: @escaping(Page?) -> ()){
        
        let body = [
            "groupId" : groupId,
            "title" : title,
            "order" : order,
            "template" : template
        ] as [String : Any]
        print(body)
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/pages") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertPage HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<PageResponse>.self, from: data) else {
                print("Error: insertPage JSON parsing failed")
                return
            }
            
            if decodedData.status == 201 {
                if let data = decodedData.data {
                    self.page = Page(id: data.id, groupId: data.groupId, pageTitle: data.pageTitle, blockResList: [Block()], pageCheckResList: [PageCheck()])
                    print(decodedData.message)
                    completion(self.page)
                }
            }
            else {
                print("insertPage failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
        }.resume()
    }
    
    func deletePage(id: Int, completion: @escaping(Bool?)->()){
        guard let url = URL(string: urlString + "/pages/\(id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.httpMethod = "DELETE"
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: deletePage error calling DELETE - \(String(describing: error))")
                return
            }
            guard let response = response as? HTTPURLResponse, (204) ~= response.statusCode else {
                
                print("Error: deletePage HTTP request failed \(response!)")
              
                return
            }

            if response.statusCode == 204 {
                print("deletePage success")
                completion(true)
            }
            else {
                print("deletePage failed")
                
            }
            
        }.resume()
    }
    
    func readPage(id: Int){
        if id != -1 {
            guard let url = URL(string: urlString + "/pages/\(id)") else {
                print("Invalid URL")
                return
            }
            print(url)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("\(projectId)", forHTTPHeaderField: "projectId")
            request.addValue("\(userId)", forHTTPHeaderField: "userId")
            let session = URLSession(configuration: .default)
            
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                // 에러검사
                guard error == nil else {
                    print("Error occur: readPage error calling GET - \(String(describing: error))")
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                    print("Error: readPage HTTP request failed")
                    return
                }
                
                let dateDecoder = JSONDecoder()
                dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
                
                guard let decodedData = try? dateDecoder.decode(ResponseModel<Page>.self, from: data) else {
                    print("Error: readPage JSON parsing failed")
                    return
                }
                if decodedData.status == 200 {
                    
                    DispatchQueue.main.async {
                        if let data = decodedData.data {
                            self.page = data
                            print(self.page)
                            print(decodedData.message)
                            self.isNewPage += 1
                        }
                    }
                }
                else {
                    print("readPage failed")
                    print(decodedData.status)
                    print(decodedData.message)
                }
                
            }
            dataTask.resume()
        }
        else {
            DispatchQueue.main.async {
                self.page = Page()
                print("newPage")
            }
        }
    }
    
    func readBlankPage(id: Int){
        guard let url = URL(string: urlString + "/pages/\(id)") else {
            print("Invalid URL")
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(projectId)", forHTTPHeaderField: "projectId")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: readBlankPage error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readBlankPage HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<BlankPage>.self, from: data) else {
                print("Error: readBlankPage JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                
                DispatchQueue.main.async {
                    if let data = decodedData.data {
                        self.blankPage = data
                        print(self.blankPage)
                        print(decodedData.message)
                    }
                }
            }
            else {
                print("readBlankPage failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
        }
        
        dataTask.resume()
    }
    
    func updatePageTitle(title: String, id: Int, groupId: Int, completion:@escaping(Bool?)->()){
        
        let body = [
            "projectId" : projectId,
            "groupId" : groupId,
            "pageId" : id,
            "title" : title
        ] as [String : Any]
        print(body)
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/pages") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: updatePageTitle error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: updatePageTitle HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: updatePage JSON parsing failed")
                return
            }
            
            if decodedData.status == 200 {
                if let data = decodedData.data {
                    completion(data)
                }
              
                print(decodedData.message)
            }
            else {
                print("updatePageTitle failed")
                print(decodedData.status)
                print(decodedData.message)
            }

        }.resume()
    }

    func getPageCheckCount()-> Int{
        var count = 0
        for i in 0..<page.pageCheckResList.count {
            if page.pageCheckResList[i].isChecked {
                count += 1
            }
        }
        
        return count
    }
    
    func getBlankPageCheckCount()-> Int{
        var count = 0
        for i in 0..<blankPage.pageCheckResList.count {
            if blankPage.pageCheckResList[i].isChecked {
                count += 1
            }
        }
        
        return count
    }
    
    func getLastCheckedDateToString(index: Int)-> String{
        return page.pageCheckResList[index].lastChecked.relativeTime
    }
    
    func getBlankLastCheckedDateToString(index: Int)-> String{
        return blankPage.pageCheckResList[index].lastChecked.relativeTime
    }
}

/// WebSocket
extension PageViewModel {
    func connectPageWebSocket(pageId: Int){
        webSocket.url = URL(string: Constants.webSocketUrl + "/ws/pages?projectId=\(projectId)&pageId=\(pageId)&userId=\(userId)")
        try? webSocket.openWebSocket()
        webSocket.delegate = self
        print( webSocket.url as Any)
        print("connectPageWebSocket")
        receiveMessage()
    }
    
    func connectBlankPageWebSocket(pageId: Int){
        webSocket.url = URL(string: Constants.webSocketUrl + "/ws/pages?projectId=\(projectId)&pageId=\(pageId)&userId=\(userId)")
        try? webSocket.openWebSocket()
        webSocket.delegate = self
        print(webSocket.url as Any)
        print("connectBlankPageWebSocket")
        receiveMessage()
    }
    
    func disconnectPageWebSocket(){
        webSocket.closeWebSocket()
    }
    
    func sendBlankPageContent(){
        let body = [
            "editorType": 0,
            "docs" : blankPage.content
        ] as [String : Any]
        
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
    }
    
    func sendBlockContent(editorType: Int, blockIndex: Int){
        let body = [
            "editorType": editorType,
            "blockId" : page.blockResList[blockIndex].id,
            "docs" : editorType == 1 ? page.blockResList[blockIndex].title : page.blockResList[blockIndex].content
        ] as [String : Any]
        
        
        let jsonCreate = (try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted))!
        let jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        webSocket.send(message: jsonObj)
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
                print("Reconnect")
                self?.connectPageWebSocket(pageId: self?.page.id ?? 0)
                
            case .success(let message):
                switch message {
                case .string(let messageString):
                    print("messageString")
                    print(messageString)
                    
                    if let dict = try? JSONSerialization.jsonObject(with: Data(messageString.utf8), options: []) as? [String:Any]{
                        DispatchQueue.main.async {
                            ///BlankPage
                            if dict["editorType"] as! Int == 0 {
                                let jsonData = JSON(dict["diffStr"]!)
                                
                                /// insert
                                if jsonData["type"] == 0 {
                                    if (self?.blankPage.content.count) ?? 0 < jsonData["diffStartIndex"].intValue {
                                        self?.blankPage.content += jsonData["subStr"].stringValue
                                    }
                                    else {
                                        self?.blankPage.content.insert(contentsOf: jsonData["subStr"].stringValue, at: (self?.blankPage.content.index((self?.blankPage.content.startIndex)!, offsetBy: jsonData["diffStartIndex"].intValue))!)
                                    }
                                }
                                /// update
                                else {
                                    var temp = 0
                                    for _ in jsonData["diffStartIndex"].intValue...jsonData["diffEndIndex"].intValue {
                                        if (self?.blankPage.content.count) ?? 0 > (jsonData["diffEndIndex"].intValue - temp) {
                                            
                                            self?.blankPage.content.remove(at: (self?.blankPage.content.index((self?.blankPage.content.startIndex)!, offsetBy: (jsonData["diffEndIndex"].intValue - temp)))!)
                                            temp += 1
                                        }
                                    }
                                    if (self?.blankPage.content.count) ?? 0 > jsonData["diffStartIndex"].intValue {
                                        self?.blankPage.content.insert(contentsOf: jsonData["subStr"].stringValue, at: (self?.blankPage.content.index((self?.blankPage.content.startIndex)!, offsetBy: jsonData["diffStartIndex"].intValue))!)
                                    }
                                    else {
                                        self?.blankPage.content += jsonData["subStr"].stringValue
                                    }
                                }
                            }
                            /// BlockPage Title
                            else if dict["editorType"] as! Int == 1 {
                                let jsonData = JSON(dict["diffStr"]!)

                                for i in 0..<(self?.page.blockResList.count)! {
                                    if self?.page.blockResList[i].id == (dict["blockId"] as! Int) {
                                        /// insert
                                        if jsonData["type"] == 0 {
                                            if (self?.page.blockResList[i].title.count)! < jsonData["diffStartIndex"].intValue {
                                                self?.page.blockResList[i].title += jsonData["subStr"].stringValue
                                            }
                                            else {
                                                self?.page.blockResList[i].title.insert(contentsOf: jsonData["subStr"].stringValue, at: (self?.page.blockResList[i].title.index(( self?.page.blockResList[i].title.startIndex)!, offsetBy: jsonData["diffStartIndex"].intValue))!)
                                            }
                                        }
                                        
                                        /// update
                                        else {
                                            var temp = 0
                                            for _ in jsonData["diffStartIndex"].intValue...jsonData["diffEndIndex"].intValue {
                                                if (self?.page.blockResList[i].title.count)! > (jsonData["diffEndIndex"].intValue - temp) {
                                                    
                                                    self?.page.blockResList[i].title.remove(at: (self?.page.blockResList[i].title.index((self?.page.blockResList[i].title.startIndex)!, offsetBy: (jsonData["diffEndIndex"].intValue - temp)))!)
                                                    temp += 1
                                                }
                                            }
                                            if (self?.page.blockResList[i].title.count)! > jsonData["diffStartIndex"].intValue {
                                                self?.page.blockResList[i].title.insert(contentsOf: jsonData["subStr"].stringValue, at: ( self?.page.blockResList[i].title.index(( self?.page.blockResList[i].title.startIndex)!, offsetBy: jsonData["diffStartIndex"].intValue))!)
                                            }
                                            else {
                                                self?.page.blockResList[i].title += jsonData["subStr"].stringValue
                                            }
                                        }
                                    }
                                }
                            }
                            
                            /// BlockPage Content
                            else {
                                let jsonData = JSON(dict["diffStr"]!)
                                
                                for i in 0..<(self?.page.blockResList.count)! {
                                    if self?.page.blockResList[i].id == dict["blockId"] as? Int {
                                        /// insert
                                        if jsonData["type"] == 0 {
                                            if (self?.page.blockResList[i].content.count)! < jsonData["diffStartIndex"].intValue {
                                                self?.page.blockResList[i].content += jsonData["subStr"].stringValue
                                            }
                                            else {
                                                self?.page.blockResList[i].content.insert(contentsOf: jsonData["subStr"].stringValue, at: (self?.page.blockResList[i].content.index(( self?.page.blockResList[i].content.startIndex)!, offsetBy: jsonData["diffStartIndex"].intValue))!)
                                            }
                                        }
                                        
                                        /// update
                                        else {
                                            var temp = 0
                                            for _ in jsonData["diffStartIndex"].intValue...jsonData["diffEndIndex"].intValue {
                                                if (self?.page.blockResList[i].content.count)! > (jsonData["diffEndIndex"].intValue - temp) {
                                                    
                                                    self?.page.blockResList[i].content.remove(at: (self?.page.blockResList[i].content.index((self?.page.blockResList[i].content.startIndex)!, offsetBy: (jsonData["diffEndIndex"].intValue - temp)))!)
                                                    temp += 1
                                                }
                                            }
                                            if (self?.page.blockResList[i].content.count)! > jsonData["diffStartIndex"].intValue {
                                                self?.page.blockResList[i].content.insert(contentsOf: jsonData["subStr"].stringValue, at: ( self?.page.blockResList[i].content.index(( self?.page.blockResList[i].content.startIndex)!, offsetBy: jsonData["diffStartIndex"].intValue))!)
                                            }
                                            else {
                                                self?.page.blockResList[i].content += jsonData["subStr"].stringValue
                                            }
                                        }
                                    }
                                }
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

/// Block
extension PageViewModel {
    func getBlockListCount()-> Int {
        if page.blockResList.count > 0 {
            return page.blockResList[0].id != -1 ? page.blockResList.count : 0
        }
        return 0
    }
    
    func changeOrderBlock(){
        blockVM.blockList = page.blockResList
        blockVM.changeOrderBlock(pageId: page.id)
    }
    
    func appendBlock(blockTitle: String){
        blockVM.insertBlock(order: page.blockResList[0].id != -1 ?  page.blockResList.count : 0, pageId: page.id, title: blockTitle){
            block in
            if let block = block {
                DispatchQueue.main.async {
                    if self.page.blockResList.count > 0 && self.page.blockResList[0].id == -1 {
                    
                        self.page.blockResList[0] = block
                        
                    }
                    else {
                        self.page.blockResList.append(block)
                    }
                    print("appendBlock success")
                }
            }
        }
    }
    
    func cloneBlock(cloneType: String, blockIndex: Int, pageId: Int){
        blockVM.cloneBlock(cloneType: cloneType, pageId: pageId, title: page.blockResList[blockIndex].title, content: page.blockResList[blockIndex].content){
            block in
            if let block = block {
                if cloneType == "THIS" {
                    DispatchQueue.main.async {
                        self.page.blockResList.append(block)
                        print("cloneBlock success")
                    }
                }
            }
        }
        
    }
    func removeBlock(blockIndex: Int) {
        blockVM.deleteBlock(blockId: self.page.blockResList[blockIndex].id){
            result in
            if result == true {
                DispatchQueue.main.async {
                    self.page.blockResList.remove(at: blockIndex)
                    print("deleteBlock success")
                }
            }
        }
    }
}

/// Annotation
extension PageViewModel {
    func appendAnnotation(content: String, blockIndex: Int){
        annotationVM.insertAnnotation(projectId: projectId, newAnnotation: Annotation(id: -1, blockId: page.blockResList[blockIndex].id, userId: userId, userName: "", content: content, lastModified: Date())){
            annot in
            if let annot = annot {
                DispatchQueue.main.async {
                    if self.page.blockResList[blockIndex].annotationList.count > 0 && self.page.blockResList[blockIndex].annotationList[0].id == -1 {
                        self.page.blockResList[blockIndex].annotationList[0] = annot
                    }
                    else {
                        self.page.blockResList[blockIndex].annotationList.append(annot)
                    }
                    print("appendAnnotation success")
                }
            }
        }
    }
    
    func getAnnotListCount(blockIndex: Int)-> Int {
        if page.blockResList.count > blockIndex {
            if page.blockResList[blockIndex].annotationList.count > 0{
                return page.blockResList[blockIndex].annotationList[0].id != -1 ? page.blockResList[blockIndex].annotationList.count : 0
            }
        }
        return 0
        
    }
    
    func getAnnotDateToString(blockIndex: Int, annotIndex: Int)-> String {
        let dateformatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier:"ko_KR")
            formatter.dateFormat = "yy-MM-dd a hh:mm"
            return formatter
        }()
        return dateformatter.string(from: page.blockResList[blockIndex].annotationList[annotIndex].lastModified)
    }
    
    func removeAnnotation(blockIndex: Int, annotIndex: Int){
        annotationVM.deleteAnnotation(id: page.blockResList[blockIndex].annotationList[annotIndex].id, projectId: projectId){
            result in
            if result == true {
                DispatchQueue.main.async {
                    self.page.blockResList[blockIndex].annotationList.remove(at: annotIndex)
                    print("deleteAnnotation success")
                }
            }
        }
    }
    
    func updateAnnotation(blockIndex: Int, annotIndex: Int, content: String) {
        annotationVM.updateAnnotation(annotationId: page.blockResList[blockIndex].annotationList[annotIndex].id, content: content){
            annot in
            if let annot = annot {
                DispatchQueue.main.async {
                    self.page.blockResList[blockIndex].annotationList[annotIndex] = annot
                    print("updateAnnotation success")
                }
            }
        }
    }
}

/// sse
extension PageViewModel {
    func openPageSSE(pageId: Int){
        let serverURL = URL(string: Constants.sseUrl + "/pages/subscribe/\(pageId)")!
        eventSource = EventSource(url: serverURL, headers: ["userId":"\(userId)"])
        
        eventSource?.connect()
        
        eventSource?.onOpen {
            print("Page Event sourced opened!")
        }
        
        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            guard reconnect ?? false else { return }
            
            let retryTime = self?.eventSource?.retryTime ?? 600000
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
                self?.eventSource?.connect()
            }
        }
        
        eventSource?.addEventListener("connect"){ id, event, data in
            print(data!)
        }
        
        eventSource?.addEventListener("enter"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<page.pageCheckResList.count {
                if page.pageCheckResList[i].userId == dict["userId"] as! Int{
                    page.pageCheckResList[i].isChecked = true
                    page.pageCheckResList[i].isEntering = true
                    page.pageCheckResList[i].lastChecked = dateformat.date(from: dict["lastChecked"] as! String)!
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("leave"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<page.pageCheckResList.count {
                if page.pageCheckResList[i].userId == dict["userId"] as! Int{
                    page.pageCheckResList[i].isChecked = true
                    page.pageCheckResList[i].isEntering = false
                    page.pageCheckResList[i].lastChecked = dateformat.date(from: dict["lastChecked"] as! String)!
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("postBlock"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            page.blockResList.append(Block(id: dict["blockId"] as! Int , pageId: dict["pageId"] as! Int , title: dict["title"] as! String , content: "" , annotationList: [Annotation()]))
            
            print(data!)
        }
        
        eventSource?.addEventListener("deleteBlock"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<page.blockResList.count {
                if page.blockResList[i].id == dict["blockId"] as! Int {
                    page.blockResList.remove(at: i)
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("postAnnotation"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }

            for i in 0..<self.page.blockResList.count {
                    if self.page.blockResList[i].id == dict["blockId"] as! Int {
                        if page.blockResList[i].annotationList.count > 0 && page.blockResList[i].annotationList[0].id == -1 {
                            page.blockResList[i].annotationList[0] = Annotation(id: dict["annotationId"] as! Int, blockId: dict["blockId"] as! Int, userId: dict["userId"] as! Int, userName: dict["userName"] as! String, content: dict["content"] as! String, lastModified: self.dateformat.date(from: dict["lastModified"] as! String)!)
                        }
                        else {
                            self.page.blockResList[i].annotationList.append(Annotation(id: dict["annotationId"] as! Int, blockId: dict["blockId"] as! Int, userId: dict["userId"] as! Int, userName: dict["userName"] as! String, content: dict["content"] as! String, lastModified: self.dateformat.date(from: dict["lastModified"] as! String)!))
                        }
                }
            }
            
            for i in 0..<self.page.blockResList.count {
                    if self.page.blockResList[i].id == dict["blockId"] as! Int {
                        for j in 0..<self.page.blockResList[i].annotationList.count {
                            print(self.page.blockResList[i].annotationList[j])
                        }
                }
            }
        }
        
        eventSource?.addEventListener("deleteAnnotation"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<page.blockResList.count{
                if page.blockResList[i].id == dict["blockId"] as! Int {
                    for j in 0..<page.blockResList[i].annotationList.count{
                        if page.blockResList[i].annotationList[j].id == dict["annotationId"] as! Int {
                            page.blockResList[i].annotationList.remove(at: j)
                        }
                    }
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("updateAnnotation"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<page.blockResList.count{
                if page.blockResList[i].id == dict["blockId"] as! Int {
                    for j in 0..<page.blockResList[i].annotationList.count{
                        if page.blockResList[i].annotationList[j].id == dict["annotationId"] as! Int {
                            page.blockResList[i].annotationList[j].content = dict["content"] as! String
                            page.blockResList[i].annotationList[j].lastModified = dateformat.date(from: dict["lastModified"] as! String)!
                        }
                    }
                }
            }
            print(data!)
        }
    }
    
    func openBlankPageSSE(pageId: Int){
        let serverURL = URL(string: Constants.sseUrl + "/pages/subscribe/\(pageId)")!
        eventSource = EventSource(url: serverURL, headers: ["userId":"\(userId)"])
        
        eventSource?.connect()
        
        eventSource?.onOpen {
            print("Page Event sourced opened!")
        }
        
        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            guard reconnect ?? false else { return }
            
            let retryTime = self?.eventSource?.retryTime ?? 600000
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
                self?.eventSource?.connect()
            }
        }
        
        eventSource?.addEventListener("connect"){ id, event, data in
            print(data!)
        }
        
        eventSource?.addEventListener("enter"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<blankPage.pageCheckResList.count {
                if blankPage.pageCheckResList[i].userId == dict["userId"] as! Int{
                    blankPage.pageCheckResList[i].isChecked = true
                    blankPage.pageCheckResList[i].isEntering = true
                    blankPage.pageCheckResList[i].lastChecked = dateformat.date(from: dict["lastChecked"] as! String)!
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("leave"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<blankPage.pageCheckResList.count {
                if blankPage.pageCheckResList[i].userId == dict["userId"] as! Int{
                    blankPage.pageCheckResList[i].isChecked = true
                    blankPage.pageCheckResList[i].isEntering = false
                    blankPage.pageCheckResList[i].lastChecked = dateformat.date(from: dict["lastChecked"] as! String)!
                }
            }
            print(data!)
        }
    }
    
    func disconnectSSE(pageId: Int){
        let serverURL = URL(string: Constants.sseUrl + "/pages/unsubscribe/\(pageId)")!
        eventSource = EventSource(url: serverURL, headers: ["userId":"\(userId)"])
        
        eventSource?.disconnect()
        print("page SSE disconnected")
        
        guard let url = URL(string:  Constants.sseUrl + "/pages/unsubscribe/\(pageId)") else {
            print("Invalid URL")
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(projectId)", forHTTPHeaderField: "projectId")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: disconnectSSE error calling GET - \(String(describing: error))")
                return
            }
        }
        dataTask.resume()
    }
     
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension PageViewModel: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("open")
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close")
    }
}

