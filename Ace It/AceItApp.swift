//
//  AceItApp.swift
//  Ace It
//
//  Created by Sam Black on 8/20/23.
//

import SwiftUI

@main
struct AceItApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var appState = AppState.shared
    @StateObject var alertVars = AlertVars.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .environmentObject(alertVars)
        }
    }
}
