//
//  speedTrackerApp.swift
//  speedTracker
//
//  Created by Hojin Moon on 6/6/23.
//

import SwiftUI

@main
struct speedTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
