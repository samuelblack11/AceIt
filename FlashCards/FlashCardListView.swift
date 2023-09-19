//
//  FlashCardListView.swift
//  FlashCards
//
//  Created by Sam Black on 9/14/23.
//

import Foundation
import SwiftUI


enum UserResponse {
    case correct
    case incorrect
}

struct FlashCardListView: View {
    let flashCards: [FlashCard]
    @State private var currentIndex: Int = 0
    @State private var userResponse: UserResponse? = nil
    @State private var correctCount: Int = 0
    @State private var questionsAttempted: Int = 0
    @State private var showingAnswer: Bool = false
    @EnvironmentObject var appState: AppState

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        if questionsAttempted == flashCards.count {
            VStack {
                CustomNavigationBar(onBackButtonTap: {appState.currentScreen = .myStacks}, titleContent: .text("Quiz Complete"))
                Text("Score: \(correctCount)/\(questionsAttempted)")
                    .font(.largeTitle)
                    .padding()

                Text("\(questionsAttempted > 0 ? (correctCount * 100 / questionsAttempted) : 0)%")
                    .font(.title)
                    .padding()

                Button("Restart") {
                    currentIndex = 0
                    correctCount = 0
                    questionsAttempted = 0
                    userResponse = nil
                    showingAnswer = false
                }
                .padding()

                Button("Return to MyStacks") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
        } else {
            VStack {
                CustomNavigationBar(onBackButtonTap: {appState.currentScreen = .myStacks}, titleContent: .text("Quiz Time"))
                HStack {
                    VStack {
                        Text("Score: \(correctCount)/\(questionsAttempted)")
                            .font(.headline)
                        Text("Out of \(flashCards.count)")
                    }
                    Spacer()
                    Text("\(questionsAttempted > 0 ? (correctCount * 100 / questionsAttempted) : 0)%")
                        .font(.headline)
                }
                .padding()
                
                FlashCardView(flashCard: flashCards[currentIndex], showingAnswer: $showingAnswer)
                
                // Correct/Incorrect Buttons
                HStack {
                    Button("Incorrect") {
                        userResponse = .incorrect
                        questionsAttempted += 1
                    }
                    .disabled(userResponse != nil)
                    
                    Spacer()
                    
                    Button("Correct") {
                        userResponse = .correct
                        correctCount += 1
                        questionsAttempted += 1
                    }
                    .disabled(userResponse != nil)
                }
                .padding()
                
                HStack {
                    Button("Previous") {
                        if currentIndex > 0 {
                            currentIndex -= 1
                            userResponse = nil // reset user response when changing card
                            showingAnswer = false // Ensure the prompt is displayed
                        }
                    }
                    .disabled(currentIndex == 0)
                    
                    Spacer()
                    
                    Button("Next") {
                        if currentIndex < flashCards.count - 1 {
                            currentIndex += 1
                            userResponse = nil // reset user response when changing card
                            showingAnswer = false // Ensure the prompt is displayed
                        }
                    }
                    .disabled(userResponse == nil || currentIndex == flashCards.count - 1) // disable until user selects a response
                    
                }
                .padding()
            }
        }
    }
}


struct FlashCardView: View {
    var flashCard: FlashCard
    @Binding var showingAnswer: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 10)
            
            // Display either prompt or answer based on the showAnswer state
            Text(showingAnswer ? flashCard.answer! : flashCard.prompt!)
                .font(.title)
                .padding()
        }
        .frame(width: 300, height: 200)
        .onTapGesture {
            withAnimation {
                showingAnswer.toggle()
            }
        }
    }
}


