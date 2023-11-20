//
//  WebSocket.swift
//  Linking
//
//  Created by 윤겸지 on 2023/04/10.
//

import Foundation
import SwiftyJSON

enum WebSocketError: Error {
    case invalidURL
}

final class WebSocket: NSObject {
    override init() {}
    
    var isOpened = false

    var url = URL(string: Constants.webSocketUrl + "/ws/chatting")
    var onReceiveClosure: ((String?, Data?) -> ())?
    weak var delegate: URLSessionWebSocketDelegate?

    var webSocketTask: URLSessionWebSocketTask? {
        didSet { oldValue?.cancel(with: .goingAway, reason: nil) }
    }
    private var timer: Timer?

    func openWebSocket() throws {
        guard let url = url else { throw WebSocketError.invalidURL }

        let urlSession = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        let webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask.resume()
        isOpened = true

        self.webSocketTask = webSocketTask

        self.startPing()
    }

    func send(message: String) {
        self.send(message: message, data: nil)
    }

    func send(data: Data) {
        self.send(message: nil, data: data)
    }

    private func send(message: String?, data: Data?) {
        let taskMessage: URLSessionWebSocketTask.Message
        if let string = message {
            taskMessage = URLSessionWebSocketTask.Message.string(string)
        } else if let data = data {
            taskMessage = URLSessionWebSocketTask.Message.data(data)
        } else {
            return
        }
        print(taskMessage)
        self.webSocketTask?.send(taskMessage, completionHandler: { error in
            guard let error = error else { return }
            print("WebSOcket sending error: \(error)")
        })
    }

    func closeWebSocket() {
        self.webSocketTask = nil
        self.timer?.invalidate()
        self.onReceiveClosure = nil
        self.delegate = nil
    }

    func receiveMessage() {

        if !isOpened {
            try! openWebSocket()
        }

        self.webSocketTask?.receive(completionHandler: { [weak self] result in

            switch result {
            case .failure(let error):
                print("error")
                print(error.localizedDescription)
            case .success(let message):
                switch message {
                case .string(let messageString):
                    print("messageString")
                    print(messageString)
        
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

    private func startPing() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(
            withTimeInterval: 45,
            repeats: true,
            block: { [weak self] _ in self?.ping() }
        )
    }
    
    private func ping() {
        self.webSocketTask?.sendPing(pongReceiveHandler: { [weak self] error in
            guard let error = error else { return }
            print("Ping failed \(error)")
            self?.startPing()
        })
    }
}

extension WebSocket: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        self.delegate?.urlSession?(
            session,
            webSocketTask: webSocketTask,
            didOpenWithProtocol: `protocol`
        )
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        self.delegate?.urlSession?(
            session,
            webSocketTask: webSocketTask,
            didCloseWith: closeCode,
            reason: reason
        )
    }
}
