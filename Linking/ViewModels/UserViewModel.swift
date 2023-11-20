//
//  UserViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/14.
//

import Foundation

class UserViewModel: ObservableObject {
    
    let urlString = Constants.baseURL
    var isEmailCheck: Bool = false
    var token = UserDefaults.standard.value(forKey: "token") as! String
    
    @Published var user = User()
    @Published var userList = [User]()
    
    func insertUser(str: String, parameters: [String : Any], completion: @escaping(Bool?)->()) {
        
        let requestBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        guard let url = URL(string: urlString + str) else {
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
                print("Error occur: insertUser error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertUser HTTP request failed")
                completion(false)
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<User>.self, from: data) else {
                print("Error: insertUser JSON parsing failed")
                return
            }
            if decodedData.status == 200{
                
                DispatchQueue.main.async {
                    if let data = decodedData.data {
                        self.user = data
                    }
                    UserDefaults.standard.set(self.user.id, forKey: "userId")
                    UserDefaults.standard.set(self.user.firstName, forKey: "firstName")
                    UserDefaults.standard.set(self.user.lastName, forKey: "lastName")
                    UserDefaults.standard.set(self.user.email, forKey: "email")
                    print(self.user)
                    print(decodedData.message)
                    NotificationViewModel.shared.insertFcmToken(token: self.token)
                }
                completion(true)
            }
            else {
                print("insertUser failed")
                print(decodedData.status)
                print(decodedData.message)
                completion(false)
            }
        }.resume()
    }
    
    func checkEmail(str: String, paramerers: [String : Any]){
        let requestBody = try! JSONSerialization.data(withJSONObject: paramerers, options: [])
        
        guard let url = URL(string: urlString + str) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error occur: checkEmail error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: checkEmail HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: checkEmail JSON parsing failed")
                return
            }
            
            self.isEmailCheck = (decodedData.data!)
            print(decodedData.message)
            print("result \(self.isEmailCheck)")
        }
        dataTask.resume()
    }
    
    func readUser(id: Int){
        
        guard let url = URL(string: urlString) else {
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
                print("Error occur: readUser error calling POST - \(String(describing: error))")
                return
            }
            
            // data 확인 response의 유효성 검사
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readUser HTTP request failed")
                return
            }
            
            // 데이터를 JSONDecoder()를 통해 User로 data를 디코딩하여 decodedData에 저장
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<User>.self, from: data) else {
                print("Error: readUser JSON parsing failed")
                return
            }
            // 디코드한 data값을 User에 저장
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    if let data = decodedData.data {
                        self.user = data
                    }
                    print(decodedData.message)
                }
            }
            else {
                print("readUser failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }
        // resume()을 불러주어야 한다. Task는 기본적으로 suspended상태로 시작한다. 따라서 이를 호출해서 data task를 시작한다.
        // Task를 실행할 경우 강한 참조를 걸어 Task가 끝나거나 실패할 때까지 유지해준다. 네트워킹이 중간에 끊기지 않도록.
        dataTask.resume()
    }
    
    func readFindUserListByEmail(partOfEmail: String, projectId: Int) {
        
        guard let url = URL(string: urlString + "/users/email") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "projectId" : projectId,
            "partOfEmail" : partOfEmail
        ] as [String : Any]
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // 에러검사
            guard error == nil else {
                print("Error occur: readFindUserListByEmail error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readFindUserListByEmail HTTP request failed")
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(ResponseModel<UserResponse>.self, from: data) else {
                print("Error: readFindUserListByEmail JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    print(decodedData.message)
                    if let data = decodedData.data {
                        self.userList = data.userList
                    }
                }
            }
            else {
                print("readFindUserListByEmail failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }
        dataTask.resume()
    }
}



