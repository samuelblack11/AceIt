//
//  AutoGenStack.swift
//  FlashCards
//
//  Created by Sam Black on 9/13/23.
//

import Foundation
import SwiftUI

struct CategoryForm: View {
    @State private var categoryName: String = ""
    @State private var description: String = "Describe your category in more detail here"
    @State private var didEditDescription: Bool = false // A flag to check if the description has been edited
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isSubmitting: Bool = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        CustomNavigationBar(onBackButtonTap: {appState.currentScreen = .mainMenu}, titleContent: .text("Create a Category"))
        Form {
            Section(header: Text("Category Details")) {
                TextField("Category Name", text: $categoryName)
                    .disabled((isSubmitting))
                TextEditor(text: $description)
                    .disabled((isSubmitting))
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                    .onTapGesture {
                        if !didEditDescription {
                            description = ""
                            didEditDescription = true
                        }
                    }
            }
            Section {
                Button(action: submit) {Text("Submit")}
                    .disabled(isSubmitting)
            }
        }
        .overlay(
            Group {
                if isSubmitting {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                        .padding()
                    //.background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
                }
            }
        )
    }
    
    func submit() {
        isSubmitting = true
        print("Category Name: \(categoryName)")
        print("Description: \(description)")
        OpenAI.shared.generateStack(category: categoryName, description: description) {
            response, error in
            defer { isSubmitting = false; appState.currentScreen = .mainMenu }  // Set to false when done, using defer to ensure it's called
            print("-----")
            print(response)
            print("-----")
            guard let unwrappedResponse = response, let dictForCore = parseResponse(unwrappedResponse) else {
                return
            }
            for (key, val) in dictForCore {
                print("***")
                print(key)
                print(val)
                saveEntryToCore(prompt: key, answer: val)
            }
            //isSubmitting = false
        }
        
    }
    
    func saveEntryToCore(prompt: String, answer: String) {
        let flashCard = FlashCard(context: viewContext)
        flashCard.category1 = categoryName
        flashCard.prompt = prompt
        flashCard.answer = answer
        do {try viewContext.save()}
        catch {print("Error saving dummy item: \(error)")}
    }
    
    func parseResponse(_ response: String) -> [String: String]? {
        let pattern = "\"([^\"]+)\": \"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let matches = regex?.matches(in: response, options: [], range: NSRange(location: 0, length: response.count))
        
        var parsedDict: [String: String] = [:]
        
        matches?.forEach {
            if let keyRange = Range($0.range(at: 1), in: response),
               let valueRange = Range($0.range(at: 2), in: response) {
                let key = String(response[keyRange])
                let value = String(response[valueRange])
                parsedDict[key] = value
            }
        }
        
        return parsedDict.isEmpty ? nil : parsedDict
    }

    
    
    
}

struct CategoryForm_Previews: PreviewProvider {
    static var previews: some View {
        CategoryForm()
    }
}
