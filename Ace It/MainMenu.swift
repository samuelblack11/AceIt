//
//  MainMenu.swift
//  Ace It
//
//  Created by Sam Black on 9/13/23.
//

import Foundation
import SwiftUI
struct MainMenu: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                CustomNavigationBar(titleContent: .text("Ace It"), showBackButton: false)
                Spacer()
                menuButton(action: {appState.currentScreen = .myStacks}, text: "My Stacks", symbolName: "books.vertical", bgColor: Color("PastelBlue"))
                menuButton(action: {appState.currentScreen = .autoGenerateStack}, text: "Auto-Generate A New Stack", symbolName: "wand.and.stars", bgColor: Color("PastelGreen"))
                menuButton(action: {appState.currentScreen = .manualEntryStack}, text: "Manually Add Cards", symbolName: "pencil", bgColor: Color("PastelYellow"))
                Spacer()
            }
        }
    }

    func menuButton(action: @escaping () -> Void, text: String, symbolName: String, bgColor: Color) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: symbolName) // SF Symbol
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    //.shadow(color: Color.black.opacity(0.3), radius: 7, x: 0, y: 5)
                Text(text)
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                    //.shadow(color: Color.black.opacity(0.3), radius: 7, x: 0, y: 5)
            }
            .padding() // Internal padding for each button for a spacious feel
            .frame(maxWidth: .infinity)
            .background(bgColor)
            .cornerRadius(15) // Rounded corners
        }
    }
}

// Define your custom colors
extension Color {
    static let pastelBlue = Color(red: 173/255, green: 216/255, blue: 230/255)
    static let pastelGreen = Color(red: 152/255, green: 251/255, blue: 152/255)
    static let pastelYellow = Color(red: 255/255, green: 239/255, blue: 213/255)
}

