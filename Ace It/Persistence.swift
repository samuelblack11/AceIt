//
//  Persistence.swift
//  Ace It
//
//  Created by Sam Black on 8/20/23.
//

import CoreData

import CoreData

struct PersistenceController {
    // Singleton instance for app-wide use
    static let shared = PersistenceController()

    // NSPersistentContainer handles the core data stack
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Ace It")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        // Load the persistent store (could be SQLite, in-memory, etc.)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                // Handle the error. You can replace fatalError() with print statements for debugging
                fatalError("Error loading persistent store: \(error)")
            }
        }

        // This ensures that the viewContext updates when background contexts save changes
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
