//
//  InterludeApp.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import SwiftData

@main
struct InterludeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Paper.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
