//
//  ContentView.swift
//  Ace It
//
//  Created by Sam Black on 8/20/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Group {
                switch appState.currentScreen {
                case .mainMenu:
                    MainMenu()
                case .myStacks:
                    MyStacks()
                case .quizMe:
                    MainMenu()
                case .newStack:
                    MainMenu()
                case .autoGenerateStack:
                    CategoryForm()
                case .manualEntryStack:
                    CreateCard()
                }
            }
        }
    }
}
