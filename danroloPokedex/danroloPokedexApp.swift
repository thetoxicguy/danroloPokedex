//
//  danroloPokedexApp.swift
//  danroloPokedex
//
//  Created by daniel.a.robles on 16/01/26.
//

import SwiftUI

@main
struct danroloPokedexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
