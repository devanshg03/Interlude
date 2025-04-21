//
//  PDFUtils.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import Foundation
import PDFKit

func extractTitle(from fileURL: URL) -> String {
    guard let pdf = PDFDocument(url: fileURL),
          let page = pdf.page(at: 0),
          let text = page.string else {
        return fileURL.deletingPathExtension().lastPathComponent
    }

    let lines = text
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

    let filteredLines = lines.filter { line in
        let lower = line.lowercased()
        return !lower.hasPrefix("arxiv:")
            && !lower.hasPrefix("published in")
            && !lower.hasPrefix("doi:")
            && !lower.contains("submitted")
            && !lower.contains("preprint")
            && !lower.contains("received")
            && !lower.contains("accepted")
            && line.count > 10 // skip 1-word junk
    }

    return filteredLines.first ?? fileURL.deletingPathExtension().lastPathComponent
}
