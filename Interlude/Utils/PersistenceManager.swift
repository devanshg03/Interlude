//
//  PersistenceManager.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import Foundation

struct PersistenceManager {
    static let folderKey = "papersFolder"
    static func saveFolder(_ url: URL) {
        UserDefaults.standard.set(url.path, forKey: folderKey)
    }
    static func loadFolder() -> URL? {
        guard let path = UserDefaults.standard.string(forKey: folderKey)
        else { return nil }
        return URL(fileURLWithPath: path)
    }
}
