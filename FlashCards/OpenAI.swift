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
    
    func generateStack(category: String, description: String, completion: @escaping ([[String: String]]?, Error?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let systemInstruction = "You are a helpful assistant."
        let userQuestion = """
        Given the category: \(category), create a JSON formatted list of dictionary entries for quizzing. Each dictionary should have a 'prompt' key for the question and an 'answer' key for its corresponding answer, considering the details: \(description). The response should look like this:
        [
            {"prompt": "Question 1?", "answer": "Answer 1"},
            {"prompt": "Question 2?", "answer": "Answer 2"},
            ...
        ]
        """
        
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
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let responses = jsonResponse["choices"] as? [[String: Any]],
                       let assistantMessage = responses.first?["message"] as? [String: Any],
                       let text = assistantMessage["content"] as? String,
                       let parsedData = text.data(using: .utf8),
                       let parsedResponse = try? JSONSerialization.jsonObject(with: parsedData) as? [[String: String]] {
                        completion(parsedResponse, nil)
                    } else {
                        completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error parsing response"]))
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }

    
    

}
