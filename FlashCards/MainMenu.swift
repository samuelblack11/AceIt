//
//  MainMenu.swift
//  FlashCards
//
//  Created by Sam Black on 9/13/23.
//

import Foundation
import SwiftUI
struct MainMenu: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack {
                CustomNavigationBar(titleContent: .text("FlashCards"), showBackButton: false)
                VStack(spacing: 0) {
                    Button(action: {appState.currentScreen = .myStacks})
                    {
                        Text("My Stacks")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.blue)
                    }
                    Divider().background(Color.gray)
                    HStack {
                        Button(action: {appState.currentScreen = .autoGenerateStack})
                        {
                            Text("Auto-Generate A New Stack")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.green)
                        }
                        Divider().background(Color.gray)
                        Button(action: {appState.currentScreen = .manualEntryStack})
                        {
                            Text("Manually Build A New Stack")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.yellow)
                        }
                        .disabled(true)
                    }
                }
            }
        }
    }
    
}
