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
    @StateObject private var appVM = AppViewModel()

    var body: some Scene {
        WindowGroup {
            if let _ = appVM.folderURL {
                LibraryContainerView()
                    .environmentObject(appVM)
                    .modelContainer(for: Paper.self, inMemory: true)
            } else {
                OnboardingView()
                    .environmentObject(appVM)
            }
        }
    }
}
