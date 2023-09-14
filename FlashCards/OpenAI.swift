//
//  OpenAI.swift
//  Inflated
//
//  Created by Sam Black on 8/20/23.
//

import Foundation

class OpenAI {
    
    var key = "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" // Replace with your API key and keep it secure.
    static let shared = OpenAI()

    private let baseURL = "https://api.openai.com/v1/chat/completions"
    

    func generateStack(category: String, description: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("json", forHTTPHeaderField: "response_format")

        let systemInstruction = "You are a helpful assistant."
        let userQuestion = "Given the category: \(category), create a series of dictionary entries that the user may wish to be quizzed on about that category. Each key/value pair should consist of a prompt or question, and the corresponding answer. Here are some additional details that the user would like you to consider for this task: \(description). Please format the dictionary entries within a list, within this style of brackets: []. Each key and value should be in quotations. Each key should be followed by a colon and each value should be followed by a comma. Ensure that the only time the characters [ and ] are in your response are at the start and end of the dictionary."
        let messages = [
            ["role": "system", "content": systemInstruction],
            ["role": "user", "content": userQuestion]
        ]
        let model = "gpt-3.5-turbo"
        
        let requestBody: [String: Any] = ["model": model, "messages": messages]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("***")
            print(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "No body data")
        } catch {
            completion(nil, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("%%%%")
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                print("\(httpResponse)")
            }
            print(response)
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let data = data else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let errorDetail = jsonResponse["error"] as? String {
                            print("OpenAI Error: \(errorDetail)")
                            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorDetail]))
                            return
                        }
                        
                        if let responses = jsonResponse["choices"] as? [[String: Any]],
                           let assistantMessage = responses.first?["message"] as? [String: Any],
                           let text = assistantMessage["content"] as? String {
                            completion(text.trimmingCharacters(in: .whitespacesAndNewlines), nil)
                        } else {
                            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error parsing response"]))
                        }
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }

}
