//
//  GroupViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/04/06.
//

import Foundation
import IKEventSource

class GroupViewModel: NSObject, ObservableObject {
    
    let urlString = Constants.baseURL
    let userId = UserDefaults.standard.integer(forKey: "userId")
    
    var pageVM = PageViewModel()
    var eventSource: EventSource?
    var projectId = 0
    
    @Published var group = PageGroup()
    @Published var groupList = [PageGroup]()
    @Published var blockGroupList = [BlockPageGroup]()
    
    func insertGroup(name: String){
        let body = [
            "projectId" : projectId,
            "name" : name,
            "order" : getGroupListCount()
        ] as [String : Any]
        
        print(body)
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/groups") else {
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
                print("Error occur: insertGroup error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertGroup HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<PageGroup>.self, from: data) else {
                print("Error: insertGroup JSON parsing failed")
                return
            }
            if decodedData.status == 201 {
                
                DispatchQueue.main.async {
                    self.group = decodedData.data!
                    self.groupList.append(self.group)
                }
                print(decodedData.message)
            }
            else {
                print("insertGroup failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
    func readGroupList(){
        
        guard let url = URL(string: urlString + "/groups/list?projectId=\(projectId)") else {
            print("Invalid URL")
            return
        }
        print(projectId)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: readGroupList error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readGroupList HTTP response failed")
                return
            }
            
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<[PageGroup]>.self, from: data) else {
                print("Error: readGroupList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.groupList = decodedData.data!
                    for i in 0..<self.groupList.count {
                        print("list \(self.groupList[i])")
                    }
                }
                print(decodedData.message)
            }
            
            else {
                print("readGroupList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }
        dataTask.resume()
    }
    
    func readBlockPageList(projectId: Int){
        
        guard let url = URL(string: urlString + "/groups/blockpages/\(projectId)") else {
            print("Invalid URL")
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: readBlockPageList error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readBlockPageList HTTP response failed")
                return
            }
            
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<[BlockPageGroup]>.self, from: data) else {
                print("Error: readBlockPageList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.blockGroupList = decodedData.data!
                    for i in 0..<self.blockGroupList.count {
                        print("list \(self.blockGroupList[i])")
                    }
                }
                print(decodedData.message)
            }
            
            else {
                print("readBlockPageList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }
        dataTask.resume()
    }
    
    func updateGroup(index: Int, name: String){
        guard let url = URL(string: urlString+"/groups") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "groupId" : groupList[index].id,
            "name" : name
        ] as [String : Any]
        print(body)
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: updateGroup error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: updateGroup HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: updateGroup JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                
                print(decodedData.message)
                DispatchQueue.main.async {
                    self.groupList[index].name = name
                }
            }
            else {
                print("updateGroup failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
    func deleteGroup(id: Int, index: Int){
        guard let url = URL(string: urlString+"/groups/\(id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: deleteGroup error calling POST - \(String(describing: error))")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (204) ~= response.statusCode else {
                print("Error: deleteGroup HTTP request failed")
                return
            }
            
            if response.statusCode == 204 {
                
                DispatchQueue.main.async {
                    self.groupList.remove(at: index)
                }
            }
            else {
                print("deleteGroup failed")
            }
            
        }.resume()
    }
    
    func changeOrderGroupAndPage(){
        
        var sendGroupList = [[String: Any]]()
        
        
        var pageList = [[String : Any]]()
        for i in 0..<groupList.count {
            for j in 0..<groupList[i].pageList.count{
                if groupList[i].pageList[j].id != -1 {
                    pageList.append(["pageId" : groupList[i].pageList[j].id])
                }
            }
            sendGroupList.append(["groupId" : groupList[i].id,
                                  "pageList" : pageList])
        }
        
        
        print(sendGroupList)
        let requestBody = try! JSONSerialization.data(withJSONObject: sendGroupList, options: [])
        
        guard let url = URL(string: urlString + "/groups/order") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: changeOrderGroupAndPage error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: changeOrderGroupAndPage HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: changeOrderGroupAndPage JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                print(decodedData.message)
                print("changeOrderGroupAndPage success")
            }
            else {
                print("changeOrderGroupAndPage failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
    func getGroupListCount()-> Int {
        if groupList.count > 0 {
            return groupList[0].id != -1 ? groupList.count : 0
        }
        return 0
    }
    
}

/// page
extension GroupViewModel {
    func appendPage(title: String, index: Int, template: String){
        pageVM.insertPage(groupId: groupList[index].id, order: getPageListCount(groupIndex: index), title: title, template: template){
            page in
            if let page = page {
                DispatchQueue.main.async {
                    if self.groupList[index].pageList.count > 0 && self.groupList[index].pageList[0].id == -1 {
                        self.groupList[index].pageList[0] = PageResponse(id: page.id, groupId: page.groupId, pageTitle: page.pageTitle, annoNotiCnt: 0, template: template)
                    }
                    else {
                        self.groupList[index].pageList.append(PageResponse(id: page.id, groupId: page.groupId, pageTitle: page.pageTitle, annoNotiCnt: 0, template: template))
                    }
                    print("appendPage success")
                }
            }
        }
    }
    
    func removePage(pageIndex:Int, groupIndex: Int){
        pageVM.deletePage(id: groupList[groupIndex].pageList[pageIndex].id) {
            result in
            if result == true {
                DispatchQueue.main.async {
                    self.groupList[groupIndex].pageList.remove(at: pageIndex)
                    print("remove page success")
                    
                }
            }
        }
    }
    
    func updatePageTitle(pageIndex:Int, groupIndex: Int, title: String){
        pageVM.updatePageTitle(title: title, id: groupList[groupIndex].pageList[pageIndex].id, groupId: groupList[groupIndex].id) {
            result in
            if result == true {
                DispatchQueue.main.async {
                    self.groupList[groupIndex].pageList[pageIndex].pageTitle = title
                    print("updatePageTitle success")
                    
                }
            }
        }
    }

    func getPageListCount(groupIndex: Int)-> Int {
        if groupList[groupIndex].pageList.count > 0 {
            return groupList[groupIndex].pageList[0].id != -1 ? groupList[groupIndex].pageList.count : 0
        }
        return 0
    }
}

/// sse
extension GroupViewModel {
    func openGroupSSE(){
        let serverURL = URL(string: Constants.sseUrl + "/groups/subscribe?projectId=\(projectId)")!
        eventSource = EventSource(url: serverURL, headers: ["userId":"\(userId)"])
        
        eventSource?.connect()
        
        eventSource?.onOpen {
            print("Group Event sourced opened!")
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
        
        eventSource?.addEventListener("postGroup"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            groupList.append(PageGroup(id: dict["groupId"] as! Int, projectId: group.projectId, name: dict["name"] as! String, pageList: [PageResponse()]))
            print(data!)
        }
        
        eventSource?.addEventListener("putGroupName"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<groupList.count {
                if groupList[i].id == dict["groupId"] as! Int {
                    groupList[i].name = dict["name"] as! String
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("deleteGroup"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<groupList.count {
                if groupList[i].id == dict["groupId"] as! Int {
                    groupList.remove(at: i)
                    break
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("postPage"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<groupList.count {
                if groupList[i].id == dict["groupId"] as! Int {
                    if groupList[i].pageList.count > 0 && groupList[i].pageList[0].id == -1 {
                        groupList[i].pageList = [PageResponse(id: dict["pageId"] as! Int, groupId: dict["groupId"] as! Int, pageTitle: dict["title"] as! String, annoNotiCnt: dict["annoNotCnt"] as! Int, template: dict["template"] as! String)]
                    }
                    else {
                        groupList[i].pageList.append(PageResponse(id: dict["pageId"] as! Int, groupId: dict["groupId"] as! Int, pageTitle: dict["title"] as! String, annoNotiCnt: dict["annoNotCnt"] as! Int, template: dict["template"] as! String))
                    }
                }
                print(groupList[i])
            }
            print(data!)
        }
        
        eventSource?.addEventListener("deletePage"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<groupList.count {
                if groupList[i].id == dict["groupId"] as! Int {
                    for j in 0..<groupList[i].pageList.count{
                        if groupList[i].pageList[j].id == dict["pageId"] as! Int
                        {
                            groupList[i].pageList.remove(at: j)
                        }
                    }
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("postAnnotation"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<groupList.count {
                if groupList[i].id == dict["groupId"] as! Int {
                    for j in 0..<groupList[i].pageList.count{
                        if groupList[i].pageList[j].id == dict["pageId"] as! Int
                        {
                            groupList[i].pageList[j].annoNotiCnt = groupList[i].pageList[j].annoNotiCnt + 1
                        }
                    }
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("deleteAnnotation"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<groupList.count {
                if groupList[i].id == dict["groupId"] as! Int {
                    for j in 0..<groupList[i].pageList.count{
                        if groupList[i].pageList[j].id == dict["pageId"] as! Int
                        {
                            groupList[i].pageList[j].annoNotiCnt = groupList[i].pageList[j].annoNotiCnt - 1
                        }
                    }
                }
            }
            print(data!)
        }
    }
    
    func disconnectSSE(){
        eventSource?.disconnect()
        print("Group SSE disconnected")
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

extension GroupViewModel: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("open")
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("close")
    }
}
