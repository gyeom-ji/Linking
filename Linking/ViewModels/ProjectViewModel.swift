//
//  ProjectViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/15.
//

import Foundation

class ProjectViewModel: ObservableObject {
    
    let urlString = Constants.baseURL
    var participantVM = ParticipantViewModel()
    
    @Published var project = Project()
    @Published var projectList = [Project()]
    @Published var isTrue: Bool = false
    @Published var percent: Float = 0.0
    @Published var dday: String = ""
    
    let dateformat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func insertProject(){
        
        var partList = [Int]()
        
        for i in 0..<project.userList.count {
            
            partList.append(project.userList[i].id)
        }
        
        let body = [
            "projectName" : project.name,
            "beginDate" : getBeginDateToString(),
            "dueDate" : getDueDateToString(),
            "partList" : partList
        ] as [String : Any]
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/projects") else {
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
                print("Error occur: insertProject error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertProject HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<Project>.self, from: data) else {
                print("Error: insertProject JSON parsing failed")
                return
            }
            
            if decodedData.status == 201 {
                DispatchQueue.main.async {
                    self.project = decodedData.data!
                    self.getDdayAndPercent()
                    self.projectList.append(self.project)
                    print(decodedData.message)
                }
            }
            
            else {
                print("insertProject failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
    func readProjectList(userId: Int, completion: @escaping(Int?) -> ()){
        guard let url = URL(string: urlString + "/projects/list/part/\(userId)") else {
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
                print("Error occur: error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readProjectList HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[Project]>.self, from: data) else {
                print("Error: readProjectList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    if let data = decodedData.data {
                        self.projectList = data
                    }
                    
                    for i in 0..<self.projectList.count {
                        print("list \(self.projectList[i])")
                        
                        if i == 0 {
                            self.project = self.projectList[i]
                            self.getDdayAndPercent()
                            UserDefaults.standard.set(self.projectList[0].id, forKey: "projectId")
                            break
                        }
                    }
                    completion(self.project.id)
                }
            }
            else {
                print("readProjectList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }
        
        dataTask.resume()
    }
    
    func readProject(index: Int){
        
        if index != -1 {
            
            guard let url = URL(string: urlString + "/projects/\(self.projectList[index].id)") else {
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
                    print("Error occur: readProject error calling GET - \(String(describing: error))")
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                    print("Error: readProject HTTP request failed")
                    return
                }
                
                let dateDecoder = JSONDecoder()
                dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
                
                guard let decodedData = try? dateDecoder.decode(ResponseModel<Project>.self, from: data) else {
                    print("Error: JSON parsing failed")
                    return
                }
                if decodedData.status == 200 {
                    DispatchQueue.main.async {
                        if let data = decodedData.data {
                            self.project = data
                        }
                        UserDefaults.standard.set(self.project.id, forKey: "projectId")
                        print(self.project)
                        self.getDdayAndPercent()
                    }
                }
                else {
                    print("readProject failed")
                    print(decodedData.status)
                    print(decodedData.message)
                }
                
            }
            
            dataTask.resume()
        }
        
        else {
            DispatchQueue.main.async {
                self.project = Project()
                self.project.userList.append(User(id: UserDefaults.standard.integer(forKey: "userId"), firstName: UserDefaults.standard.string(forKey: "firstName")!, lastName: UserDefaults.standard.string(forKey: "lastName")!, email: UserDefaults.standard.string(forKey: "email")!))
            }
        }
        
        
    }
    
    func updateProject(index: Int, isPartListChanged: Bool){
        
        var partList = [Int]()
        
        for i in 0..<project.userList.count {
            
            partList.append(project.userList[i].id)
        }
        
        guard let url = URL(string: urlString+"/projects") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "projectId" : project.id,
            "projectName" : project.name,
            "beginDate" : getBeginDateToString(),
            "dueDate" : getDueDateToString(),
            "partList" : partList,
            "isPartListChanged" : isPartListChanged
        ] as [String : Any]
        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: updateProject error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: updateProject HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<Project>.self, from: data) else {
                print("Error: updateProject JSON parsing failed")
                return
            }
            
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.project = decodedData.data!
                    self.getDdayAndPercent()
                    self.projectList[index] = self.project
                    print(self.project)
                }
            }
            else {
                print("updateProject failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
        
    }
    
    func deleteProject(id: Int, index: Int){
        
        guard let url = URL(string: urlString+"/projects/\(id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: deleteProject error calling DELETE - \(String(describing: error))")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (204) ~= response.statusCode else {
                print("Error: deleteProject HTTP request failed")
                return
            }
            
            if response.statusCode == 204 {
                print("deleteProject success")
                DispatchQueue.main.async {
                    self.projectList.remove(at: index)
                }
            }
            else {
                print("deleteProject failed")
                
            }
            
        }.resume()
    }
    
    func appendUser(newUser: User){
        
//        participantVM.insertParticipant(userId: newUser.id, projectId: project.id) {
//            participant in
//            if let participant = participant {
//                DispatchQueue.main.async {
            self.project.userList.append(newUser)
//                }
//            }
//        }
        
    }
    
    func getUserListCount()-> Int {
        print(project.userList.count)
        return project.userList.count
    }
    
    func removeUser(index: Int){
        participantVM.deleteParticipant(projectId: project.id, userId: project.userList[index].id) {
            result in
            if result == true {
                DispatchQueue.main.async {
                    self.project.userList.remove(at: index)
                }
            }
        }
    }
    
    func getBeginDateToString()-> String{
        return dateformat.string(from: project.beginDate)
    }
    
    func getBeginDateToString(index: Int)-> String{
        return dateformat.string(from: projectList[index].beginDate)
    }
    
    func getDueDateToString()-> String{
        return dateformat.string(from: project.dueDate)
    }
    
    func getDueDateToString(index: Int)-> String{
        return dateformat.string(from: projectList[index].dueDate)
    }
    
    func getDdayAndPercent() {
        
        let tempStart = dateformat.string(from: project.beginDate)
        let tempDue = dateformat.string(from: project.dueDate)
        
        let betweenBeginDueDate = dateformat.date(from: tempDue)!.timeIntervalSince(dateformat.date(from: tempStart)!)

        let betweenTodayDueDate = dateformat.date(from: tempDue)!.timeIntervalSince(Date())
        dday = Int(betweenTodayDueDate / 86400) >= 0 ? "마감까지 \(Int(betweenTodayDueDate / 86400) + 1)일" : "마감된 프로젝트 입니다"
        print(dday)
        if betweenBeginDueDate > 0 && betweenTodayDueDate > 0 {
            percent = Float((betweenTodayDueDate / 86400) / (betweenBeginDueDate / 86400))
        }
        else {
            percent = 1.0
        }
    }
    
}
