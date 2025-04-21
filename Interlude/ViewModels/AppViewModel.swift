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
    @Published var folderURL: URL?
    @Published var selectedPaperID: UUID? = nil
    @Published var selectedTag: String?
    @Published var readFilter: ReadFilter = .all
    
    var allPapers: [Paper] = []

    var selectedPaper: Paper? {
        allPapers.first(where: { $0.id == selectedPaperID })
    }

    init() {
        UserDefaults.standard.removeObject(forKey: "papersFolder")
        // restore last folder via UserDefaults
        if let path = UserDefaults.standard.string(forKey: "papersFolder") {
            folderURL = URL(fileURLWithPath: path)
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
            folderURL = url
            UserDefaults.standard.set(url.path, forKey: "papersFolder")
        }
    }
}
