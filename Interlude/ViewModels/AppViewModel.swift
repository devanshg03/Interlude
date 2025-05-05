//
//  AppViewModel.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import Foundation

enum ReadFilter: String, CaseIterable, Identifiable {
    case all = "All", read = "Read", unread = "Unread"
    var id: Self { self }
}

final class AppViewModel: ObservableObject {
    @Published var selectedPaperID: UUID? = nil
    @Published var selectedTag: String?
    @Published var readFilter: ReadFilter = .all
    @Published var folderURL: URL?

    var allPapers: [Paper] = []

    var selectedPaper: Paper? {
        allPapers.first(where: { $0.id == selectedPaperID })
    }

    init() {
        // Load previously selected folder from security-scoped bookmark
        if let bookmarkData = UserDefaults.standard.data(forKey: "papersFolderBookmark") {
            var isStale = false
            if let restoredURL = try? URL(
                resolvingBookmarkData: bookmarkData,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            ) {
                if restoredURL.startAccessingSecurityScopedResource() {
                    folderURL = restoredURL
                } else {
                    print("⚠️ Failed to access security-scoped resource.")
                }
            } else {
                print("⚠️ Failed to restore folder bookmark.")
            }
        }
    }

    func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories      = true
        panel.canChooseFiles            = false
        panel.allowsMultipleSelection   = false
        panel.prompt                    = "Select Papers Folder"
        panel.title                     = "Choose Your Papers Folder"

        if panel.runModal() == .OK, let url = panel.url {
            if url.startAccessingSecurityScopedResource() {
                folderURL = url

                // Save folder bookmark instead of raw path
                if let bookmark = try? url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                ) {
                    UserDefaults.standard.set(bookmark, forKey: "papersFolderBookmark")
                } else {
                    print("⚠️ Failed to create bookmark for folder.")
                }
            } else {
                print("⚠️ Failed to access security-scoped resource for selected folder.")
            }
        }
    }
}

