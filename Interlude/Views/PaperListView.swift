//
//  PaperListView.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import SwiftData

struct PaperListView: View {
    let papers: [Paper]
    @Binding var selectedID: UUID?
    let selectedTag: String?
    let readFilter: ReadFilter

    var filtered: [Paper] {
        papers.filter { p in
            (selectedTag == nil || p.tags.contains(selectedTag!)) &&
            (readFilter == .all ||
             (readFilter == .read && p.isRead) ||
             (readFilter == .unread && !p.isRead))
        }
    }

    var body: some View {
        List(selection: $selectedID) {
            ForEach(filtered) { paper in
                HStack(spacing: 10) {
                    // ⬤ Dot indicator for unread
                    if !paper.isRead {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 6, height: 6)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 6, height: 6)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(paper.title)
                            .font(.headline)
                            .lineLimit(1)

                        Text(paper.filename)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()
                }
                .padding(.vertical, 6)
                .tag(paper.id)
            }
        }
        .listStyle(.sidebar)
    }
}
