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
                CustomNavigationBar(onBackButtonTap: {self.presentationMode.wrappedValue.dismiss()}, titleContent: .text("Quiz Complete"))
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
                    Spacer() // This spacer pushes the buttons to the center
                    
                    Button(action: {
                        userResponse = .incorrect
                        questionsAttempted += 1
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(userResponse == .incorrect ? .white : .red)
                            .background(
                                Circle()
                                    .fill(userResponse == .incorrect ? Color.red : Color.clear)
                                    .frame(width: 40, height: 40)
                            )
                    }
                    .disabled(userResponse != nil)
                    .padding() // Add padding for some space between the buttons

                    Button(action: {
                        userResponse = .correct
                        correctCount += 1
                        questionsAttempted += 1
                    }) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(userResponse == .correct ? .white : .green)
                            .background(
                                Circle()
                                    .fill(userResponse == .correct ? Color.green : Color.clear)
                                    .frame(width: 40, height: 40)
                            )
                    }
                    .disabled(userResponse != nil)
                    .padding()

                    Spacer() // This spacer pushes the buttons to the center
                }
                .padding()
                HStack {
                   // Button("Previous") {
                    //    if currentIndex > 0 {
                    //        currentIndex -= 1
                    //        userResponse = nil // reset user response when changing card
                    //        showingAnswer = false // Ensure the prompt is displayed
                    //    }
                    //}
                    //.disabled(currentIndex == 0)
                    
                    //Spacer()
                    
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
        let textToShow = showingAnswer ? flashCard.answer! : flashCard.prompt!
        let (text1, text2, text3) = splitText(textToShow)

        return ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 10)
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.5), lineWidth: 2) // Light blue border

            VStack(spacing: 10) { // Adjust this value if you need more/less space between text and lines
                Spacer() // Pushes content to the center
                Text(text1)
                    .font(.title)
                Line()
                Text(text2)
                    .font(.title)
                Line()
                Text(text3)
                    .font(.title)
                Spacer() // Pushes content to the center
            }
            .padding(.vertical, 10) // Ensure it doesn't touch the top/bottom
        }
        .frame(width: UIScreen.screenWidth/1.1, height: 200)
        .onTapGesture {
            withAnimation {showingAnswer.toggle()}
        }
    }

    
    func splitText(_ originalText: String) -> (String, String, String) {
        let maxCharsPerLine = 18
        var currentIndex = originalText.startIndex
        
        let getText: () -> String = {
            if currentIndex < originalText.endIndex {
                let tentativeEndIndex = originalText.index(currentIndex, offsetBy: maxCharsPerLine, limitedBy: originalText.endIndex) ?? originalText.endIndex

                // If we're not at the end of the string and the next character isn't a space, backtrack to the last space
                var adjustedEndIndex = tentativeEndIndex
                if tentativeEndIndex < originalText.endIndex && originalText[tentativeEndIndex] != " " {
                    adjustedEndIndex = originalText[..<tentativeEndIndex].lastIndex(of: " ") ?? tentativeEndIndex
                }

                return String(originalText[currentIndex..<adjustedEndIndex])
            }
            return ""
        }

        if originalText.count <= maxCharsPerLine {
            return ("", originalText, "")
        } else {
            let text1 = getText()
            currentIndex = originalText.index(currentIndex, offsetBy: min(text1.count, maxCharsPerLine))

            let text2 = getText()
            currentIndex = originalText.index(currentIndex, offsetBy: min(text2.count, maxCharsPerLine))

            let text3 = getText()

            return (text1, text2, text3)
        }
    }
}





// Custom view for lines
struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color.blue.opacity(0.5)) // Light blue color for the line
            .frame(height: 1)
    }
}
