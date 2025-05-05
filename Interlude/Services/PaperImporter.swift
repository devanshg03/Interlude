//
//  PaperImporter.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import Foundation
import SwiftData
import PDFKit

@MainActor                        // <- ensure ModelContext always on main queue
struct PaperImporter {

    /// Import a single PDF → Paper
    static func importPDF(at url: URL, into context: ModelContext) {
        let filename = url.lastPathComponent
        let title    = defaultTitle(for: url)

        // skip duplicates
        let fetch = FetchDescriptor<Paper>(predicate: #Predicate { $0.filename == filename })
        if let found = try? context.fetch(fetch), !found.isEmpty { return }

        let paper = Paper(title: title,
                          filename: filename,
                          authors: [],
                          tags: [],
                          isRead: false)
        context.insert(paper)
        try? context.save()
    }

    /// Quick heuristic: first non‑empty line of first page
    private static func defaultTitle(for url: URL) -> String {
        guard
            let doc  = PDFDocument(url: url),
            let page = doc.page(at: 0),
            let text = page.string
        else { return url.deletingPathExtension().lastPathComponent }

        let first = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty } ?? ""
        return first.count > 10 ? first : url.deletingPathExtension().lastPathComponent
    }
}
