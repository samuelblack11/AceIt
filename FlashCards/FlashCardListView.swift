//
//  FlashCardListView.swift
//  FlashCards
//
//  Created by Sam Black on 9/14/23.
//

import Foundation
import SwiftUI

struct FlashCardListView: View {
    let flashCards: [FlashCard]
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack {
            FlashCardView(flashCard: flashCards[currentIndex])
            HStack {
                Button("Previous") {
                    if currentIndex > 0 {currentIndex -= 1}
                }
                .disabled(currentIndex == 0)
                Spacer()
                Button("Next") {
                    if currentIndex < flashCards.count - 1 {currentIndex += 1}
                }
                .disabled(currentIndex == flashCards.count - 1)
            }
            .padding()
        }
    }
}

struct FlashCardView: View {
    var flashCard: FlashCard

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 10)
            
            Text(flashCard.prompt!)
                .font(.title)
                .padding()
        }
        .frame(width: 300, height: 200)
    }
}
