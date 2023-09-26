//
//  CreateCard.swift
//  Ace It
//
//  Created by Sam Black on 9/20/23.
//

import Foundation
import SwiftUI

struct CreateCard: View {
    @State private var categoryName: String = ""
    @State private var prompt: String = ""
    @State private var answer: String = ""
    @State private var isTextBlank: Bool = true
    @State private var description: String = "Describe your category in more detail here"
    @State private var didEditAnswer: Bool = false // A flag to check if the description has been edited
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isSubmitting: Bool = false
    @EnvironmentObject var appState: AppState
    @State private var showSuccessMessage = false

    var body: some View {
        VStack {
            CustomNavigationBar(onBackButtonTap: {appState.currentScreen = .mainMenu}, titleContent: .text("Add a Card Manually"))
            
            Form {
                Section(header: Text("Card Details")) {
                    // Category Field
                    TextField("Category", text: $categoryName)
                        .disabled(isSubmitting)
                        .onChange(of: categoryName) { _ in updateIsTextBlank()}

                    // Prompt Field
                    TextField("Prompt", text: $prompt)
                        .disabled(isSubmitting)
                        .frame(height: 50)
                        .onChange(of: prompt) { _ in updateIsTextBlank()}

                    // Answer Field
                    TextField("Answer", text: $answer)
                        .disabled(isSubmitting)
                        .onChange(of: answer) { _ in updateIsTextBlank()}
                        .frame(height: 50)
                        .foregroundColor(didEditAnswer ? .primary : .gray)
                        .onTapGesture {
                            if !didEditAnswer {
                                answer = ""
                                didEditAnswer = true
                            }
                        }
                }
                if showSuccessMessage {
                    Text("Card added successfully")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.green)
                        .opacity(showSuccessMessage ? 1 : 0)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5))
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
                    }
                }
            )
        }
    }

    func updateIsTextBlank() {
        isTextBlank = categoryName.isEmpty || prompt.isEmpty || answer.isEmpty || (!didEditAnswer && (answer == "Answer" || prompt == "Prompt" || categoryName == "Category"))
    }
    
    func submit() {
        isSubmitting = true
        let fetchRequest = CardCategory.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "catName == %@", categoryName)
        do {
            let existingCategories = try viewContext.fetch(fetchRequest)
            if existingCategories.isEmpty {
                // No category with the given catName exists, so we save a new one
                OpenAI.shared.generateCategoryImage(prompt: categoryName) { (imageData, error) in
                    saveCategoryToCore(catName: categoryName, image: imageData)
                }
            } else {print("Category with name \(categoryName) already exists!")}
        } catch {
            print("Failed to fetch categories from Core Data:", error)
        }
        saveCardToCore(cardPrompt: prompt, cardAnswer: answer)
        isSubmitting = false
    }

    
    func saveCategoryToCore(catName: String, image: Data?) {
        let category = CardCategory(context: viewContext)
        category.catName = categoryName
        category.catImage = image!
        do {try viewContext.save()}
        catch {print("Error saving dummy item: \(error)")}
    }
    
    func saveCardToCore(cardPrompt: String, cardAnswer: String) {
        let flashCard = FlashCard(context: viewContext)
        flashCard.category1 = categoryName
        flashCard.prompt = cardPrompt
        flashCard.answer = cardAnswer
        do {try viewContext.save()
            withAnimation {showSuccessMessage = true}
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                 withAnimation {showSuccessMessage = false}
             }
            categoryName = ""
            prompt = ""
            answer = ""
        }
        catch {print("Error saving dummy item: \(error)")}
    }
}
