//
//  Paper.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import Foundation
import SwiftData

@Model
class Paper {
    var title: String
    var filename: String
    var authors: [String]
    var tags: [String]
    var isRead: Bool
    var addedDate: Date

    init(title: String, filename: String, authors: [String] = [], tags: [String] = [], isRead: Bool = false, addedDate: Date = .now) {
        self.title = title
        self.filename = filename
        self.authors = authors
        self.tags = tags
        self.isRead = isRead
        self.addedDate = addedDate
    }
}
