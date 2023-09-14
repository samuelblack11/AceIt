//
//  InflatedApp.swift
//  Inflated
//
//  Created by Sam Black on 8/20/23.
//

import SwiftUI

@main
struct FlashCardsApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
        }
    }
}
