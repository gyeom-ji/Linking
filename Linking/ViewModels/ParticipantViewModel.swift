//
//  ParticipantViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/04/01.
//

import Foundation

class ParticipantViewModel: ObservableObject {
    
    let urlString = Constants.baseURL
    
    @Published var participant = Participant()
    @Published var participantList = [Participant]()
    
    func insertParticipant(userId: Int, projectId: Int, completion: @escaping(Participant?) -> ()){
        
        let body = [
            "userId" : userId,
            "projectId" : projectId
        ] as [String : Any]
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/participant") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Participant>.self, from: data) else {
                print("Error: JSON parsing failed")
                return
            }
            
            if decodedData.status == 201 {
                
                self.participant = decodedData.data!
                completion(self.participant)
                
            }
            else {
                print("insertPage failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
    func readParticipantList(projectId: Int){
        guard let url = URL(string: urlString + "/participant/list?proj-id=\(projectId)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode([Participant].self, from: data) else {
                print("Error: JSON parsing failed")
                return
            }
            
            self.participantList = decodedData.self
        }
        
        dataTask.resume()
    }
    
    func readParticipant(id: Int){
        guard let url = URL(string: urlString + "/participant?id=\(id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                print("Error occur: error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(Participant.self, from: data) else {
                print("Error: JSON parsing failed")
                return
            }
            
            self.participant = decodedData.self
        }
        dataTask.resume()
    }
    
    func deleteParticipant(projectId: Int, userId: Int, completion: @escaping(Bool?)->()){
        
        guard let url = URL(string: urlString+"/participant/single") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "projectId" : projectId,
            "userId" : userId
        ] as [String : Any]
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: error calling POST - \(String(describing: error))")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (204) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
            //delete success
            if response.statusCode == 204 {
                completion(true)
            }
            else {
                print("deleteParticipant failed")
            
            }
            
        }.resume()
    }
}
