//
//  BlockViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/25.
//

import Foundation

class BlockViewModel: ObservableObject {
    let urlString = Constants.baseURL
    let userId = UserDefaults.standard.integer(forKey: "userId")
    
    @Published var block = Block()
    @Published var blockList = [Block]()
    
    func insertBlock(order: Int, pageId: Int, title:String, completion: @escaping(Block?) -> ()){
        
        let body = [
            "order" : order,
            "pageId" : pageId,
            "title" : title
        ] as [String : Any]
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/blocks" ) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: insertBlock error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertBlock HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Int>.self, from: data) else {
                print("Error: insertBlock JSON parsing failed")
                return
            }
            
            if decodedData.status == 201 {
                if let data = decodedData.data {
                    self.block = Block(id: data, pageId: pageId, title: title, content: "", annotationList: [Annotation()])
                    completion(self.block)
                }
            }
            else {
                print("insertBlock failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
            print("result \(self.block)")
        }.resume()
    }
    
    func cloneBlock(cloneType: String, pageId: Int, title:String, content:String, completion: @escaping(Block?) -> ()){
        
        let body = [
            "cloneType" : cloneType,
            "title" : title,
            "content" : content,
            "pageId" : pageId
        ] as [String : Any]
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        print(body)
        guard let url = URL(string: urlString + "/blocks/clone" ) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: copyBlock error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: copyBlock HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Int>.self, from: data) else {
                print("Error: copyBlock JSON parsing failed")
                return
            }
            
            if decodedData.status == 201 {
                if let data = decodedData.data {
                    self.block = Block(id: data, pageId: pageId, title: title, content: content, annotationList: [Annotation()])
                    completion(self.block)
                }
            }
            else {
                print("copyBlock failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
            print("result \(self.block)")
        }.resume()
    }
    
    func updateBlock(){
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(block) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: updateBlock error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: updateBlock HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(Block.self, from: data) else {
                print("Error: updateBlock JSON parsing failed")
                return
            }
            
            self.block = decodedData.self
            
        }.resume()
    }
    
    func deleteBlock(blockId: Int, completion: @escaping(Bool?)->()){
        guard let url = URL(string: urlString + "/blocks/\(blockId)") else {
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
                print("Error occur: deleteBlock error calling DELETE - \(String(describing: error))")
                return
            }
            guard let response = response as? HTTPURLResponse, (204) ~= response.statusCode else {
                print("Error: deleteBlock HTTP request failed")
                return
            }
            
            if response.statusCode == 204 {
                print("deleteBlock success")
               completion(true)
            }
            else {
                print("deleteBlock failed")
            }
            
        }.resume()
    }
    
    func changeOrderBlock(pageId: Int){
        guard let url = URL(string: urlString + "/blocks/order") else {
            print("Invalid URL")
            return
        }
        
        var sendBlockList = [Int]()
        
        for i in 0..<blockList.count {
            sendBlockList.append(blockList[i].id)
        }
 
        let body = [
            "pageId" : pageId,
            "blockIds" : sendBlockList
        ] as [String : Any]
        
       
        print(body)
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: changeOrderBlock error calling POST - \(String(describing: error))")
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: changeOrderBlock HTTP request failed")
                return
            }

            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: changeOrderBlock JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                print(decodedData.message)
                print("changeOrderBlock success")
            }
            else {
                print("changeOrderBlock failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }

    func readBlock(id: Int){
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                print("Error occur: readBlock error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readBlock HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(Block.self, from: data) else {
                print("Error: readBlock JSON parsing failed")
                return
            }
            
            self.block = decodedData.self
        }
        dataTask.resume()
    }
}
