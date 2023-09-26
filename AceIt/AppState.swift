//
//  AppState.swift
//  Ace It
//
//  Created by Sam Black on 9/13/23.
//

import Foundation


class AppState: ObservableObject {
    static let shared = AppState()
    enum Screen {
        case mainMenu
        case myStacks
        case quizMe
        case newStack
        case autoGenerateStack
        case manualEntryStack
    }
    @Published var currentScreen: Screen = .mainMenu
}
