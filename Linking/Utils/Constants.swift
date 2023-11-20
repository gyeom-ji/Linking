//
//  Constants.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/14.
//

import Foundation
import AppKit
import SwiftUI

struct Constants {
    static let baseURL = "http://43.201.231.51:8080"
    static let webSocketUrl = "ws://43.201.231.51:8080"
    static let sseUrl = "http://43.201.231.51:8080"
}

enum HttpMethod<Body> {
    case get
    case post(Body?)
    case put(Body)
    case patch(Body)
    case delete(Body?)
}

extension URLRequest {
    init<Body: Encodable> (url: URL, method: HttpMethod<Body>) {
        self.init(url: url)

        switch method {
        case .get:
            self.httpMethod = "GET"
        case .post(let body):
            self.httpMethod = "POST"
            self.httpBody = try? JSONEncoder().encode(body)
        case .put(let body):
            self.httpMethod = "PUT"
            self.httpBody = try? JSONEncoder().encode(body)
        case .patch(let body):
            self.httpMethod = "PATCH"
            self.httpBody = try? JSONEncoder().encode(body)
        case .delete(let body):
            self.httpMethod = "DELETE"
            self.httpBody = try? JSONEncoder().encode(body)
        }
    }
}

extension URLSession {
    func request<T: Decodable>(_ urlRequest: URLRequest, completion: @escaping(T?, Error?) -> Void) {
        dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
                completion(nil, error)
            }
            
            if let response = response as? HTTPURLResponse,
                 (200..<300).contains(response.statusCode),
                 let data = data {
                print("URLSession data: \(String(describing: data))")
                let decodedData = try? JSONDecoder().decode(T.self, from: data)
                completion(decodedData, nil)
            }
        }.resume()
    }
}

extension Date {
    
    func getAllDates() -> [Date] {
        
        let calendar = Calendar.current
        
        // get start date
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from:  self ))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)
        
        // get date...
        return range!.compactMap{ day -> Date in
            return calendar.date(byAdding: .day, value: day - 1 , to: startDate)!
        }
    }
    
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}


extension String {
    
    subscript(_ index: Int) -> Character {
            return self[self.index(self.startIndex, offsetBy: index)]
        }
    
    mutating func replace(characterAt index: Int, with newChar: Character) {
        var chars = Array(self)
        if index >= 0 && index < self.count {
            chars[index] = newChar
            let modifiedString = String(chars)
            self = modifiedString
        } else {
            print("can't replace character, its' index out of range!")
        }
    }
}
