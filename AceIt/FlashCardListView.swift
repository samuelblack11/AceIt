//
//  FlashCardListView.swift
//  Ace It
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
    @State var flashCards: [FlashCard]
    @State private var currentIndex: Int = 0
    @State private var userResponse: UserResponse? = nil
    @State private var correctCount: Int = 0
    @State private var questionsAttempted: Int = 0
    @State private var showingAnswer: Bool = false
    @EnvironmentObject var appState: AppState
    @State private var cardHeight: CGFloat = 125
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if questionsAttempted == flashCards.count {QuizComplete(flashCards: $flashCards, currentIndex: $currentIndex, userResponse: $userResponse, correctCount: $correctCount, questionsAttempted: $questionsAttempted, showingAnswer: $showingAnswer, cardHeight: $cardHeight)}
        else {QuizView(flashCards: $flashCards, currentIndex: $currentIndex, userResponse: $userResponse, correctCount: $correctCount, questionsAttempted: $questionsAttempted, showingAnswer: $showingAnswer, cardHeight: $cardHeight)}
    }
}

struct QuizView: View {
    @Binding var flashCards: [FlashCard]
    @Binding var currentIndex: Int
    @Binding var userResponse: UserResponse?
    @Binding var correctCount: Int
    @Binding var questionsAttempted: Int
    @Binding var showingAnswer: Bool
    @EnvironmentObject var appState: AppState
    @Binding var cardHeight: CGFloat
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            CustomNavigationBar(onBackButtonTap: {presentationMode.wrappedValue.dismiss()}, titleContent: .text("Quiz Time"))
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
            Spacer()
            FlashCardView(flashCard: flashCards[currentIndex], showingAnswer: $showingAnswer, cardHeight: $cardHeight)
                .frame(width: UIScreen.main.bounds.width/1.1, height: cardHeight)
            Spacer()
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


struct QuizComplete: View {
    @Binding var flashCards: [FlashCard]
    @Binding var currentIndex: Int
    @Binding var userResponse: UserResponse?
    @Binding var correctCount: Int
    @Binding var questionsAttempted: Int
    @Binding var showingAnswer: Bool
    @EnvironmentObject var appState: AppState
    @Binding var cardHeight: CGFloat
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            CustomNavigationBar(onBackButtonTap: {presentationMode.wrappedValue.dismiss()}, titleContent: .text("Quiz Complete"))
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

            Button("Return to My Stacks") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
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

struct FlashCardView: View {
    var flashCard: FlashCard
    @Binding var showingAnswer: Bool
    @Binding var cardHeight: CGFloat

    var body: some View {
        let textToShow = showingAnswer ? flashCard.answer! : flashCard.prompt!
        let lines = splitText(textToShow)
        let spacing = (cardHeight - 5) / 6 // Considering 5 lines and 6 spaces

        return ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 10)
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.5), lineWidth: 2)

            VStack(alignment: .center, spacing: spacing) {
                ForEach(0..<5) { index in
                    Group {
                        if index < lines.count && !lines[index].isEmpty {
                            Text(lines[index])
                                .foregroundColor(Color.black)
                                .font(.title)
                                .frame(height: spacing)
                                .padding(.top, index == 0 ? spacing : 0)
                                .padding(.bottom, index == lines.count - 1 ? spacing : 0)
                        }
                        else {Spacer().frame(height: spacing)}
                    }
                    if index < 4 {Line().frame(height: 1)}
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width/1.1, height: cardHeight)
        .onTapGesture { withAnimation { showingAnswer.toggle() } }
    }

    func splitText(_ originalText: String) -> [String] {
        let words = originalText.split(separator: " ")
        var currentLine = ""
        var lines: [String] = []
        
        for word in words {
            if currentLine.count + word.count + (currentLine.isEmpty ? 0 : 1) <= 25 {
                currentLine += (currentLine.isEmpty ? "" : " ") + word
            } else {
                lines.append(currentLine)
                currentLine = String(word)
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        // Handle centering the lines
        let numEmptySlots = 5 - lines.count
        let numPrependedSlots = numEmptySlots / 2
        let numAppendedSlots = numEmptySlots - numPrependedSlots
        
        for _ in 0..<numPrependedSlots {
            lines.insert("", at: 0)
        }
        
        for _ in 0..<numAppendedSlots {
            lines.append("")
        }
        
        return lines
    }
}
