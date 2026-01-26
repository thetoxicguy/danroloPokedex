//
//  danroloPokedexApp.swift
//  danroloPokedex
//
//  Created by daniel.a.robles on 16/01/26.
//

import SwiftUI
import SwiftData

@main
struct danroloPokedexApp: App {
//    This is substituted for the SwiftData controller
//    let persistenceController = PersistenceController.shared
    var sharedModelContainer: SharedModelContainer = {
        let schema = Schema([
            Pokemon.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [ModelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    } ()

    var body: some Scene {
        WindowGroup {
            ContentView()
//            This modifier is substituted for SwiftData usage
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .modelContainer(sharedModelContainer)
        }
    }
}
