//
//  AnnotationViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/25.
//

import Foundation

class AnnotationViewModel: ObservableObject {
    let urlString = Constants.baseURL
    let userId = UserDefaults.standard.integer(forKey: "userId")
    
    @Published var annotation = Annotation()
    @Published var annotationList = [Annotation]()
    
    let dateformat: DateFormatter = {
          let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.dateFormat = "yy-MM-dd a HH:mm"
           return formatter
       }()
    
    func insertAnnotation(projectId: Int, newAnnotation: Annotation, completion: @escaping(Annotation?)->()){
        
        let body = [
            "content" : newAnnotation.content,
            "blockId" : newAnnotation.blockId ,
            "projectId" : projectId,
            "userId" : userId
        ] as [String : Any]
        print(body)
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/annotations") else {
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
                print("Error occur: insertAnnotation error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertAnnotation HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<Annotation>.self, from: data) else {
                print("Error: insertAnnotation JSON parsing failed")
                return
            }
            
            if decodedData.status == 201 {
                
                self.annotation = decodedData.data!
                print(decodedData.message)
                completion(self.annotation)
                
            }
            else {
                print("insertAnnotation failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
            print("result \(self.annotation)")
        }.resume()
    }
    
    func updateAnnotation(annotationId: Int, content: String, completion: @escaping(Annotation?)->()){
        
        let body = [
            "annotationId" : annotationId,
            "content" : content
        ] as [String : Any]
        
        print(body)
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/annotations") else {
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
                print("Error occur: updateAnnotation error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: updateAnnotation HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<Annotation>.self, from: data) else {
                print("Error: updateAnnotation JSON parsing failed")
                return
            }
            
            if decodedData.status == 200 {
                
                self.annotation = decodedData.data!
                print(decodedData.message)
                completion(self.annotation)
                
            }
            else {
                print("updateAnnotation failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
            print("result \(self.annotation)")
            
        }.resume()
    }
    
    func deleteAnnotation(id: Int, projectId:Int, completion: @escaping(Bool?)->()){
        guard let url = URL(string: urlString + "/annotations/\(id)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.addValue("\(projectId)", forHTTPHeaderField: "projectId")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.httpMethod = "DELETE"
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: deleteAnnotation error calling DELETE - \(String(describing: error))")
                return
            }

            guard let response = response as? HTTPURLResponse, (204) ~= response.statusCode else {
                print("Error: deleteAnnotation HTTP request failed")
                return
            }
            
            if response.statusCode == 204 {
                print("deleteAnnotation success")
               completion(true)
            }
            else {
                print("deleteAnnotation failed")
            }
        }.resume()
    }
    
    func readAnnotation(id: Int){
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
                print("Error occur: readAnnotation error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readAnnotation HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Annotation>.self, from: data) else {
                print("Error: readAnnotation JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.annotation = decodedData.data!
                }
                print(decodedData.message)
            }
            else {
                print("readAnnotation failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }
        dataTask.resume()
    }
    
    func readAnnotationList(blockId: Int){
        guard let url = URL(string: urlString + "/annotations/\(blockId)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession(configuration: .default)

        let dataTask = session.dataTask(with: request) { (data, response, error) in

            guard error == nil else {
                print("Error occur: readAnnotationList error calling POST - \(String(describing: error))")
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readAnnotationList HTTP request failed")
                return
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy-MM-dd"

            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[Annotation]>.self, from: data) else {
                print("Error: readAnnotationList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.annotationList = decodedData.data!
                }
                print(decodedData.message)
                print(self.annotationList)
            }
            else {
                print("readAnnotationList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }
        dataTask.resume()
    }
}
