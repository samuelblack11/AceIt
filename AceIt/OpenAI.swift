//
//  OpenAI.swift
//  Inflated
//
//  Created by Sam Black on 8/20/23.
//

import Foundation

class OpenAI {
    
    var key = OpenAIConfig.key
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
        Generate a response in a specific format based on the category: \(category) and the details: \(description). I need the response to have the following structure:

        {
            "category": "\(category)",
            "details": "\(description)",
            "questions": [
                {"prompt": "Question 1?", "answer": "Answer 1"},
                {"prompt": "Question 2?", "answer": "Answer 2"},
                ...
            ]
        }
        
        I want you to create a series of prompts and answers based on the category and details that I have provided. Each prompt should be unique to the corresponding answer.
        Prompts and answers should be fact based and not opinionated. Both prompts and answers should be limited to a maximum of 125 characters. Both the prompts and answers should be concise so that a user would be able to guess the exact answer to the prompt. The answer to any given prompt should NOT be included in the prompt itself. There should always bet 10 sets of prompts and answers for each series.
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
            if let httpResponse = response as? HTTPURLResponse {print("Status Code: \(httpResponse.statusCode)")}
            DispatchQueue.main.async {
                if let error = error {
                    print("ERROR")
                    print(error.localizedDescription)
                    completion(nil, error)
                    return
                }

                guard let data = data else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }
                do {
                    guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to JSON dictionary"]))
                        return
                    }
                    print("---")
                    print(jsonResponse)

                    guard let choicesArray = jsonResponse["choices"] as? [[String: Any]],
                          let firstChoice = choicesArray.first,
                          let messageDict = firstChoice["message"] as? [String: Any],
                          let contentText = messageDict["content"] as? String,
                          let contentData = contentText.data(using: .utf8),
                          let contentJSON = try? JSONSerialization.jsonObject(with: contentData) as? [String: Any],
                          let questionsArray = contentJSON["questions"] as? [[String: String]] else {
                              completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse the OpenAI response"]))
                              return
                    }
                    completion(questionsArray, nil)


                } catch {
                    completion(nil, error)
                }

            }
        }
        task.resume()
    }

    
    func generateCategoryImage(prompt: String, n: Int = 1, size: String = "1024x1024", completion: @escaping (Data?, Error?) -> Void) {
        print("Generating Category Image.....")
        // Endpoint for the DALL·E API
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        // Set up the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request body
        let instruction = "The image should not include any people or faces in it. The image should be focused entirely on the prompt itself."
        let promptAndInstruction = prompt + instruction
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "n": n,
            "size": size
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(nil, error)
            return
        }

        // Execute the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                }
                return
            }
            
            do {
                // Convert the data to a dictionary
                guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let imageUrls = jsonResponse["data"] as? [[String: String]],
                      let firstImageUrl = imageUrls.first?["url"],
                      let imageUrl = URL(string: firstImageUrl) else {
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to process image URL"]))
                    }
                    return
                }

                // Download the image data
                let imageDataTask = URLSession.shared.dataTask(with: imageUrl) { (imageData, _, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(nil, error)
                        } else {
                            completion(imageData, nil)
                        }
                    }
                }
                imageDataTask.resume()

            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }

}
