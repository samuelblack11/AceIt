//
//  AutoGenStack.swift
//  Ace It
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
    @State private var isTextBlank: Bool = true
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var alertVars: AlertVars

    var body: some View {
        VStack {
            CustomNavigationBar(onBackButtonTap: {appState.currentScreen = .mainMenu}, titleContent: .text("Create a Category"))
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $categoryName)
                        .disabled((isSubmitting))
                        .onChange(of: categoryName) { _ in updateIsTextBlank()}
                    TextEditor(text: $description)
                        .disabled((isSubmitting))
                        .onChange(of: description) { _ in updateIsTextBlank()}
                        .frame(height: 100)
                        .foregroundColor(didEditDescription ? .primary : .gray)
                        .onTapGesture {
                            if !didEditDescription {
                                description = ""
                                didEditDescription = true
                            }
                        }
                }
                Section {
                    Button(action: submit) {Text("Submit").frame(maxWidth: .infinity, alignment: .center)}
                        .disabled(isTextBlank || isSubmitting)
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
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {isSubmitting = false; appState.currentScreen = .mainMenu}))
    }
    
    func updateIsTextBlank() {
        isTextBlank = categoryName.isEmpty || (description.isEmpty || description == "Describe your category in more detail here" && !didEditDescription)
    }
    
    func submit() {
        isSubmitting = true
        print("Category Name: \(categoryName)")
        print("Description: \(description)")
        
        OpenAI.shared.generateStack(category: categoryName, description: description) { (response: [[String: String]]?, error: Error?) in
           // defer { isSubmitting = false; appState.currentScreen = .mainMenu }
            
            guard let unwrappedResponse = response else { return }
            let dictForCore = parseResponse(unwrappedResponse)
            if let unwrappedDict = dictForCore {
                for (key, val) in unwrappedDict {
                    saveCardToCore(prompt: key, answer: val)
                    alertVars.alertType = .stackCreated
                    alertVars.activateAlert = true
                }
                OpenAI.shared.generateCategoryImage(prompt: categoryName) { (imageData, error) in
                    saveCategoryToCore(catName: categoryName, image: imageData)
                }
            }
        }
    }
    
    func saveCategoryToCore(catName: String, image: Data?) {
        let category = CardCategory(context: viewContext)
        category.catName = categoryName
        category.catImage = image!
        do {try viewContext.save()}
        catch {print("Error saving dummy item: \(error)")}
    }
    
    func saveCardToCore(prompt: String, answer: String) {
        let flashCard = FlashCard(context: viewContext)
        flashCard.category1 = categoryName
        flashCard.prompt = prompt
        flashCard.answer = answer
        do {try viewContext.save()}
        catch {print("Error saving dummy item: \(error)")}
    }
    
    func parseResponse(_ response: [[String: String]]) -> [String: String]? {
        var parsedDict: [String: String] = [:]

        for entry in response {
            if let key = entry["prompt"], let value = entry["answer"] {
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
