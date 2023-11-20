//
//  ToDoViewModel.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/26.
//

import Foundation
import IKEventSource

class ToDoViewModel: ObservableObject {
    let urlString = Constants.baseURL
    let userId = UserDefaults.standard.integer(forKey: "userId")
    var projectId : Int = 0
    var emitterId: Int = -1
    var eventSource: EventSource?
    var calendarVM = CalendarViewModel()
    
    @Published var childTodo = ChildToDoModel()
    @Published var myTodoList = [MyToDoModel]()
    @Published var todo = ToDoModel()
    @Published var todoList = [ToDoModel]()
    @Published var assignsCompletionList = [AssignsCompletionModel]()
    @Published var todayTeamTodoList = [ToDoModel]()
    @Published var teamMember = [TeamMember]()
    
    let dateformat: DateFormatter = {
          let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd hh:mm a"
           return formatter
       }()
    
    func insertTodo(parentId: Int){
        
        var assignList = [Int]()
        
        print(childTodo.assignList as Any)
        for i in 0..<childTodo.assignList.count {
            assignList.append(childTodo.assignList[i].userId)
        }
        
        let body = [
            "emitterId" : emitterId,
            "projectId": projectId,
            "parentId": parentId,
            "isParent": childTodo.isParent,
            "startDate": getBeginDateToString(),
            "dueDate": getDueDateToString()[0] + " " + getDueDateToString()[1] + " " + getDueDateToString()[2],
            "content": childTodo.content,
            "assignList": assignList
        ] as [String : Any]
   
        print(body)
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        guard let url = URL(string: urlString + "/todos/new") else {
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
                print("Error occur: insertTodo error calling POST - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: insertTodo HTTP request failed")
                return
            }

            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[Int]>.self, from: data) else {
                print("Error: insertTodo JSON parsing failed")
                return
            }
            
            if decodedData.status == 201 {
                DispatchQueue.main.async {
                    print(decodedData.message)
                    
                    self.childTodo.id = decodedData.data![0]
                    for i in 0..<self.childTodo.assignList.count {
                        self.childTodo.assignList[i].id = decodedData.data![i+1]
                    }
                    
                    if self.childTodo.isParent == true {
                       
                        self.todoList.append(ToDoModel(id: self.childTodo.id, startDate: self.childTodo.startDate, dueDate: self.childTodo.dueDate, content: self.childTodo.content, isParent: self.childTodo.isParent, assignList: self.childTodo.assignList))
                            
                    }
                    else {
                        for i in 0..<self.todoList.count{
                            if self.todoList[i].id == parentId {
                                if self.todoList[i].childTodoList != nil {
                                    self.todoList[i].childTodoList?.append(self.childTodo)
                                }
                                else {
                                    self.todoList[i].childTodoList = [self.childTodo]
                                }
                            }
                        }
                    }
                    self.calendarVM.getDayFromTodoList(todoList: self.todoList)
                }
            }
            
            else {
                print("insertTodo failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
    func readDailyTodoList(year: String, month: String, day: Int) {
        guard let url = URL(string: urlString + "/todos/list/daily/project/\(projectId)/\(year)/\(month)/\(day)") else {
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
                print("Error occur: readDailyTodoList error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readDailyTodoList HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[ToDoModel]>.self, from: data) else {
                print("Error: readDailyTodoList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.todoList = decodedData.data!
                    for i in 0..<self.todoList.count {
                        print(self.todoList[i])
                    }
                }
            }
            else {
                print("readDailyTodoList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
        }
        dataTask.resume()
    }
    
    func readMonthlyTodoList(year: String, month: String) {

        guard let url = URL(string: urlString + "/todos/list/monthly/project/\(projectId)/\(year)/\(month)") else {
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
                print("Error occur: readMonthlyTodoList error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readMonthlyTodoList HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[ToDoModel]>.self, from: data) else {
                print("Error: readMonthlyTodoList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    print(decodedData.message)
                    self.todoList = decodedData.data!
                    self.calendarVM.getDayFromTodoList(todoList: self.todoList)
                    for i in 0..<self.todoList.count {
                        print("list \(self.todoList[i])")
                    }
                }
            }
            else {
                print("readMonthlyTodoList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
        }
        dataTask.resume()
    }
    
    func readTodo(id: Int) {
        if id != -1 {
            guard let url = URL(string: urlString + "/todos/single/\(id)") else {
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
                    print("Error occur: readTodo error calling GET - \(String(describing: error))")
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                    print("Error: readTodo HTTP request failed")
                    return
                }
                
                let dateDecoder = JSONDecoder()
                dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
                
                guard let decodedData = try? dateDecoder.decode(ResponseModel<ChildToDoModel>.self, from: data) else {
                    print("Error: readTodo JSON parsing failed")
                    return
                }
                if decodedData.status == 200 {
                    DispatchQueue.main.async {
                        self.childTodo = decodedData.data!
                        print(self.childTodo)
                        self.readTeamMember()
                    }
                }
                else {
                    print("readTodo failed")
                    print(decodedData.status)
                    print(decodedData.message)
                }
                
            }
            
            dataTask.resume()
        }
        else {
            DispatchQueue.main.async {
                self.childTodo = ChildToDoModel()
                self.readTeamMember()
            }
        }
    }
    
    func readTeamMember() {
            guard let url = URL(string: urlString + "/participants/list/project/\(projectId)") else {
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
                    print("Error occur: readTeamMember error calling GET - \(String(describing: error))")
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                    print("Error: readTeamMember HTTP request failed")
                    return
                }
                
                let dateDecoder = JSONDecoder()
                dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
                
                guard let decodedData = try? dateDecoder.decode(ResponseModel<[TeamMember]>.self, from: data) else {
                    print("Error: readTeamMember JSON parsing failed")
                    return
                }
                if decodedData.status == 200 {
                    DispatchQueue.main.async {
                        self.teamMember = decodedData.data!
                        print(self.childTodo)
                        for i in 0..<self.teamMember.count {
                            self.teamMember[i].isSelected = false
                            for j in 0..<self.childTodo.assignList.count {
                                if self.teamMember[i].userId == self.childTodo.assignList[j].userId {
                                    self.teamMember[i].isSelected = true
                                }
                            }
                        }
                    }
                }
                else {
                    print("readTodo failed")
                    print(decodedData.status)
                    print(decodedData.message)
                }
                
            }
            
            dataTask.resume()
    }
    func readTodayMyToDoList(){
        guard let url = URL(string: urlString + "/todos/list/today/user/\(userId)/urgent") else {
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
                print("Error occur: readTodayMyToDo error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readTodayMyToDo HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[MyToDoModel]>.self, from: data) else {
                print("Error: readTodayMyToDo JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.myTodoList = decodedData.data!
                    print(self.myTodoList)
                }
            }
            else {
                print("readTodayMyToDoList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
        }
        dataTask.resume()
    }
    
    func readTodayTeamTodoList(){
        guard let url = URL(string: urlString + "/todos/list/today/project/\(projectId)/urgent") else {
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
                print("Error occur: readTodayProjectTodoList error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: readTodayProjectTodoList HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[ToDoModel]>.self, from: data) else {
                print("Error: readTodayProjectTodoList JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.todayTeamTodoList = decodedData.data!
                    print("TeamTodoList")
                    print(self.todayTeamTodoList)
                }
            }
            else {
                print("readTodayProjectTodoList failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
        }
        dataTask.resume()
    }
    
    func updateTodo(parentId: Int, isAssignListChanged: Bool) {
        var assignList = [Int]()
        
        for i in 0..<childTodo.assignList.count {
            
            assignList.append(childTodo.assignList[i].userId)
        }
        
        let body = [
            "todoId": childTodo.id,
            "projectId": projectId,
            "parentId": parentId,
            "isParent": childTodo.isParent,
            "startDate": getBeginDateToString(),
            "dueDate": getDueDateToString()[0] + " " + getDueDateToString()[1] + " " + getDueDateToString()[2],
            "content": childTodo.content,
            "assignList": assignList,
            "isAssignListChanged" : isAssignListChanged
        ] as [String : Any]
        
        print(body)
        guard let url = URL(string: urlString+"/todos") else {
            print("Invalid URL")
            return
        }

        
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: updateTodo error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: updateTodo HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<Int>.self, from: data) else {
                print("Error: updateTodo JSON parsing failed")
                return
            }
            
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    if parentId == -1 {
                        for i in 0..<self.todoList.count {
                            if self.todoList[i].id == self.childTodo.id {
                                self.todoList[i].startDate = self.childTodo.startDate
                                self.todoList[i].dueDate = self.childTodo.dueDate
                                self.todoList[i].content = self.childTodo.content
                                self.todoList[i].assignList = self.childTodo.assignList
                            }
                        }
                    }
                    else {
                        for i in 0..<self.todoList.count {
                            if self.todoList[i].id == parentId {
                                for j in 0..<self.todoList[i].childTodoList!.count {
                                    if self.todoList[i].childTodoList![j].id == self.childTodo.id{
                                        self.todoList[i].childTodoList![j].startDate = self.childTodo.startDate
                                        self.todoList[i].childTodoList![j].dueDate = self.childTodo.dueDate
                                        self.todoList[i].childTodoList![j].content = self.childTodo.content
                                        self.todoList[i].childTodoList![j].assignList = self.childTodo.assignList
                                    }
                                 }
                            }
                        }
                    }
                    print(decodedData.message)
                }
            }
            else {
                print("updateTodo failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
    }
    
    func deleteTodo(id: Int, parentId: Int){
        guard let url = URL(string: urlString+"/assigns") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "emitterId" : emitterId,
            "userId" : userId,
            "projectId" : projectId,
            "todoId": id,
        ] as [String : Any]
        
        print(body)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = requestBody
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("Error occur: deleteTodo error calling DELETE - \(String(describing: error))")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (204) ~= response.statusCode else {
                print("Error: deleteTodo HTTP request failed")
                return
            }
            
            if response.statusCode == 204 {
                
                DispatchQueue.main.async {
                    if parentId == -1  {
                                for i in 0..<self.todoList.count{
                                    if self.todoList[i].id == id {
                                        if self.todoList[i].assignList.count > 1 {
                                            for j in 0..<self.todoList[i].assignList.count{
                                                if self.todoList[i].assignList[j].userId == self.userId {
                                                    self.todoList[i].assignList.remove(at: j)
                                                    break
                                                }
                                            }
                                        }
                                        else {
                                            self.todoList.remove(at: i)
                                            break
                                        }
                                    }
                                }
                    }
                    else{
                        if self.todoList.count > 0 {
                            for i in 0..<self.todoList.count{
                                
                                if self.todoList[i].id == parentId {
                                    
                                    for j in 0..<self.todoList[i].childTodoList!.count{
                                        
                                        if self.todoList[i].childTodoList?[j].id == id {
                                            
                                            if self.todoList[i].childTodoList![j].assignList.count > 1 {
                                                
                                                for k in 0..<self.todoList[i].childTodoList![j].assignList.count{
                                                    
                                                    if self.todoList[i].childTodoList![j].assignList[k].userId == self.userId {
                                                        self.todoList[i].childTodoList![j].assignList.remove(at: k)
                                                        break
                                                    }
                                                }
                                            }
                                            else {
                                                self.todoList[i].childTodoList?.remove(at: j)
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    print("deleteTodo success")
                }
            }
            else {
                print("deleteTodo failed")
                
            }
            
        }.resume()
    }
    
    func getAssignsCompletionRatio(){
        guard let url = URL(string: urlString + "/assigns/ratio/project/\(projectId)") else {
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
                print("Error occur: getAssignsCompletionRatio error calling GET - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: getAssignsCompletionRatio HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<[AssignsCompletionModel]>.self, from: data) else {
                print("Error: getAssignsCompletionRatio JSON parsing failed")
                return
            }
            if decodedData.status == 200 {
                DispatchQueue.main.async {
                    self.assignsCompletionList = decodedData.data!
                    print(self.assignsCompletionList)
                }
            }
            else {
                print("getAssignsCompletionRatio failed")
                print(decodedData.status)
                print(decodedData.message)
            }
            
        }
        
        dataTask.resume()
    }
    
    func changeMyTodoStatus(id: Int, status: ToDoStatus, myTodoIndex: Int){
        
        guard let url = URL(string: urlString+"/assigns/status") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "emitterId" : emitterId,
            "assignId" : id,
            "status" : status.rawValue,
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
                print("Error occur: changeTodoStatus error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: changeTodoStatus HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: changeTodoStatus JSON parsing failed")
                return
            }
            
            if decodedData.status == 200 {
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    print(decodedData.message)
                    self.myTodoList[myTodoIndex].status = status
                }
            }
            else {
                print("changeTodoStatus failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
        
    }
    
    func changeTeamTodoStatus(id: Int, status: ToDoStatus, teamTodoIndex: Int, assignIndex: Int, childIndex: Int){
        print("status")
        guard let url = URL(string: urlString+"/assigns/status") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "emitterId" : emitterId,
            "assignId" : id,
            "status" : status.rawValue,
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
                print("Error occur: changeTodoStatus error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: changeTodoStatus HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: changeTodoStatus JSON parsing failed")
                return
            }
            
            if decodedData.status == 200 {
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    print(decodedData.message)
                    if childIndex == -1 {
                        self.todayTeamTodoList[teamTodoIndex].assignList[assignIndex].status = status
                    }
                    else {
                        self.todayTeamTodoList[teamTodoIndex].childTodoList![childIndex].assignList[assignIndex].status = status
                    }
                }
            }
            else {
                print("changeTodoStatus failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
        
    }
    
    func changeTodoStatus(id: Int, status: ToDoStatus, todoIndex: Int, assignIndex: Int, childIndex: Int){
        
        guard let url = URL(string: urlString+"/assigns/status") else {
            print("Invalid URL")
            return
        }
        
        let body = [
            "emitterId" : emitterId,
            "assignId" : id,
            "status" : status.rawValue,
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
                print("Error occur: changeTodoStatus error calling PUT - \(String(describing: error))")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("Error: changeTodoStatus HTTP request failed")
                return
            }
            
            let dateDecoder = JSONDecoder()
            dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
            
            guard let decodedData = try? dateDecoder.decode(ResponseModel<Bool>.self, from: data) else {
                print("Error: changeTodoStatus JSON parsing failed")
                return
            }
            
            if decodedData.status == 200 {
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    print(decodedData.message)
                    if childIndex == -1 {
                        self.todoList[todoIndex].assignList[assignIndex].status = status
                    }
                    else {
                        self.todoList[todoIndex].childTodoList![childIndex].assignList[assignIndex].status = status
                    }
                }
            }
            else {
                print("changeTodoStatus failed")
                print(decodedData.status)
                print(decodedData.message)
            }
        }.resume()
        
    }
    
    func getBeginDateToString()-> String{
        return dateformat.string(from: childTodo.startDate)
    }
    
    func getBeginDateToString(index: Int)-> String{
        return dateformat.string(from: todoList[index].startDate)
    }
    
    func getDueDateToString()->[String]{
        let date = dateformat.string(from: childTodo.dueDate)
        return date.components(separatedBy: " ")
    }
    
    func getTodoListDueDateToString(index: Int)-> [String]{
        let date = dateformat.string(from: todoList[index].dueDate)
        return date.components(separatedBy: " ")
    }
    
    func getTodoListStartDateToString(index: Int)-> [String]{
        let date = dateformat.string(from: todoList[index].startDate)
        return date.components(separatedBy: " ")
    }
    
    func getTodoListChildDueDateToString(index: Int, childIndex: Int)-> [String]{
        let date = dateformat.string(from: todoList[index].childTodoList![childIndex].dueDate)
        return date.components(separatedBy: " ")
    }
    
    func getTodoListChildStartDateToString(index: Int, childIndex: Int)-> [String]{
        let date = dateformat.string(from: todoList[index].childTodoList![childIndex].startDate)
        return date.components(separatedBy: " ")
    }
    
    func getTodoDueDateToString()-> [String]{
        let date = dateformat.string(from: todo.dueDate)
        return date.components(separatedBy: " ")
    }
    
    func getTodayTeamDueDateToString(index: Int)-> [String]{
        let date = dateformat.string(from: todayTeamTodoList[index].dueDate)
        return date.components(separatedBy: " ")
    }
    
    func getTodayTeamChildDueDateToString(index: Int, childIndex: Int)-> [String]{
        let date = dateformat.string(from: todayTeamTodoList[index].childTodoList![childIndex].dueDate)
        return date.components(separatedBy: " ")
    }
    
    func getMyTodoDueDateToString(index: Int)-> [String]{
        let date = dateformat.string(from: myTodoList[index].dueDate)
        return date.components(separatedBy: " ")
    }
    
    func appendAssign(assign: AssignModel){
        childTodo.assignList.append(assign)
    }
}

/// sse
extension ToDoViewModel {
    func openTodoSSE(){
        let serverURL = URL(string: Constants.sseUrl + "/todos/connect/mac/project/\(projectId)/user/\(userId)")!
        eventSource = EventSource(url: serverURL)
        eventSource?.connect()
        
        eventSource?.onOpen {
            print("Todo Event sourced opened!")
        }
        
        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            guard reconnect ?? false else { return }
            
            let retryTime = self?.eventSource?.retryTime ?? 600000
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
                self?.eventSource?.connect()
            }
        }
        
        eventSource?.addEventListener("connect"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            emitterId = dict["emitterId"] as! Int
            print(data!)
        }
        
        eventSource?.addEventListener("postParent"){ [self] id, event, data in
            guard let parent = convertToTodoModel(text: data!) else {
                return
            }
            
            todoList.append(ToDoModel(id: parent.id, startDate: parent.startDate, dueDate: parent.dueDate, content: parent.content, isParent: parent.isParent, assignList: parent.assignList))
            calendarVM.getDayFromTodoList(todoList: todoList)
            print("post Parent")
        }
        
        eventSource?.addEventListener("postChild"){ [self] id, event, data in
            guard let child = convertToTodoModel(text: data!) else {
                return
            }
            
            for i in 0..<todoList.count {
                if todoList[i].id == child.parentId! {
                    todoList[i].childTodoList?.append(child)
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("updateParent"){ [self] id, event, data in
            guard let parent = convertToTodoModel(text: data!) else {
                return
            }
            
            for i in 0..<todoList.count {
                if todoList[i].id == parent.id {
                    todoList[i].startDate =  parent.startDate
                    todoList[i].dueDate = parent.dueDate
                    todoList[i].content = parent.content
                    todoList[i].assignList = parent.assignList
                }
            }
            calendarVM.getDayFromTodoList(todoList: todoList)
            print(data!)
        }
        
        eventSource?.addEventListener("updateChild"){ [self] id, event, data in
            guard let child = convertToTodoModel(text: data!) else {
                return
            }
            for i in 0..<todoList.count {
                if todoList[i].id == child.parentId! {
                    if todoList[i].childTodoList != nil {
                        for j in 0..<todoList[i].childTodoList!.count {
                            if todoList[i].childTodoList![j].id == child.id {
                                todoList[i].childTodoList![j].startDate =  child.startDate
                                todoList[i].childTodoList![j].dueDate = child.dueDate
                                todoList[i].childTodoList![j].content = child.content
                                todoList[i].childTodoList![j].assignList = child.assignList
                            }
                        }
                    }
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("updateParentStatus"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }

            for i in 0..<todoList.count {
                if todoList[i].id == dict["todoId"] as! Int{
                    for j in 0..<todoList[i].assignList.count {
                        if todoList[i].assignList[j].id == dict["assignId"] as! Int {
                            todoList[i].assignList[j].status = ToDoStatus(rawValue: dict["status"] as! String) ?? .basic
                            print(todoList[i].assignList[j].status)
                        }
                    }
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("updateChildStatus"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<todoList.count {
                if todoList[i].id == dict["parentId"] as! Int{
                    if todoList[i].childTodoList != nil {
                        for j in 0..<todoList[i].childTodoList!.count {
                            if todoList[i].childTodoList![j].id == dict["todoId"] as! Int {
                                for k in 0..<todoList[i].childTodoList![j].assignList.count {
                                    if todoList[i].childTodoList![j].assignList[k].id == dict["assignId"] as! Int {
                                        todoList[i].childTodoList![j].assignList[k].status = ToDoStatus(rawValue: dict["status"] as! String) ?? .basic
                                        print(todoList[i].childTodoList![j].assignList[k].status)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            print(data!)
        }
        
        eventSource?.addEventListener("deleteParent"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<todoList.count{
                if todoList[i].id == dict["todoId"] as! Int {
                    todoList.remove(at: i)
                    break
                }
            }
            calendarVM.getDayFromTodoList(todoList: todoList)
            print(data!)
        }
        
        eventSource?.addEventListener("deleteChild"){ [self] id, event, data in
            guard let dict = convertToDictionary(text: data!) else {
                return
            }
            for i in 0..<todoList.count{
                if todoList[i].id == dict["parentId"] as! Int {
                    if todoList[i].childTodoList != nil {
                        for j in 0..<todoList[i].childTodoList!.count {
                            if todoList[i].childTodoList![j].id == dict["todoId"] as! Int {
                                todoList[i].childTodoList!.remove(at: j)
                                break
                            }
                        }
                    }
                }
            }
            print(data!)
        }
    }
    
    func disconnectSSE(){
        let serverURL = URL(string: Constants.sseUrl + "/todos/disconnect/\(emitterId)")!
        eventSource = EventSource(url: serverURL)
        
        eventSource?.disconnect()
        print("Todo SSE disconnected")
        
        guard let url = URL(string:  Constants.sseUrl + "/todos/disconnect/\(emitterId)") else {
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
    
    func convertToTodoModel(text: String) -> ChildToDoModel? {
        if let data = text.data(using: .utf8) {
            do {
                let dateDecoder = JSONDecoder()
                dateDecoder.dateDecodingStrategy = .formatted(self.dateformat)
                return try dateDecoder.decode(ChildToDoModel.self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
