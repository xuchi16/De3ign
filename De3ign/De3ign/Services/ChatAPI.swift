//
//  ChatRequest.swift
//  test2
//
//  Created by Michael on 2024/8/23.
//

import Foundation

struct ChatRequest: Codable {
    let message: String
    let personality: String
}

struct ChatResponse: Codable {
    let response: String
}

func sendChatMessage(message: String, personality: String = "", completion: @escaping (String?) -> Void) {
    completion("好的，\(message)，我是一个\(personality)")
    return
    // Prepare the URL
    guard let url = URL(string: "http://124.222.130.161:15551/chat") else {
        print("Invalid URL")
        completion(nil)
        return
    }

    // Create the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Prepare the message
    let chatRequest = ChatRequest(message: message, personality: personality)
    
    do {
        let jsonData = try JSONEncoder().encode(chatRequest)
        request.httpBody = jsonData
    } catch {
        print("Failed to encode message: \(error)")
        completion(nil)
        return
    }

    // Create the task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Failed to send request: \(error)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("No data received")
            completion(nil)
            return
        }

        // Decode the response
        do {
            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            completion(chatResponse.response)
        } catch {
            print("Failed to decode response: \(error)")
            completion(nil)
        }
    }

    // Start the task
    task.resume()
}



