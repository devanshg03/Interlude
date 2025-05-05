//
//  PaperDetailView.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import PDFKit

struct PaperDetailView: View {
    @EnvironmentObject var appVM: AppViewModel
    @ObservedObject var paper: Paper

    @State private var pdfView: PDFView?            // ← hold the PDFView
    @State private var isEditingTitle = false
    @State private var draftTitle: String = ""
    @State private var isReadyToLoad = false

    var body: some View {
        VStack(spacing: 0) {
            // ───────── Top toolbar ─────────
            HStack {
                // Title edit as before…
                if isEditingTitle {
                    TextField("Title", text: $draftTitle)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)
                        .frame(maxWidth: 400)
                    Button {
                        DispatchQueue.main.async {
                            paper.title = draftTitle
                            isEditingTitle = false
                        }
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text(paper.title)
                        .font(.title2).bold().lineLimit(1)
                    Button {
                        draftTitle = paper.title
                        isEditingTitle = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // ── Annotation toolbar ──
                HStack(spacing: 12) {
                    Button(action: { annotate(.highlight) }) {
                        Image(systemName: "highlighter")
                    }
                    .help("Highlight")

                    Button(action: { annotate(.underline) }) {
                        Image(systemName: "underline")
                    }
                    .help("Underline")

                    Button(action: { annotate(.strikeOut) }) {
                        Image(systemName: "strikethrough")
                    }
                    .help("Strike-through")

                    Button(action: addNote) {
                        Image(systemName: "note.text")
                    }
                    .help("Add Note")
                }
                .buttonStyle(.plain)

                // Read/unread toggle
                Button {
                    DispatchQueue.main.async { paper.isRead.toggle() }
                } label: {
                    Text(paper.isRead ? "Mark Unread" : "Mark Read")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            Divider()

            // ────────── PDF Container ──────────
            Group {
                if isReadyToLoad {
                    if let folder = appVM.folderURL {
                        let fullURL = folder.appendingPathComponent(paper.filename)
                        if FileManager.default.fileExists(atPath: fullURL.path),
                           let _ = PDFDocument(url: fullURL) {
                            PDFKitView(url: fullURL, pdfViewRef: $pdfView)
                                .edgesIgnoringSafeArea(.all)
                        } else {
                            Text("🚫 PDF not found:\n\(paper.filename)")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        Text("⚠️ No folder selected")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    ProgressView("Loading PDF…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            draftTitle = paper.title
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isReadyToLoad = true
            }
        }
    }

    // MARK: – Annotation Helpers

    enum MarkupType {
        case highlight, underline, strikeOut
    }

    private func annotate(_ type: MarkupType) {
        guard let pdfView = pdfView,
              let selection = pdfView.currentSelection else { return }

        for page in selection.pages {
            let lines = selection
                .selectionsByLine()            // break multi-line selection
                .filter { $0.pages.contains(page) }
            for lineSel in lines {
                let bounds = lineSel.bounds(for: page)
                let annotation = PDFAnnotation(bounds: bounds,
                                               forType: markupSubtype(type),
                                               withProperties: nil)
                annotation.color = .yellow.withAlphaComponent(0.4)
                page.addAnnotation(annotation)
            }
        }
    }

    private func markupSubtype(_ type: MarkupType) -> PDFAnnotationSubtype {
        switch type {
        case .highlight:  return .highlight
        case .underline:  return .underline
        case .strikeOut:  return .strikeOut
        }
    }

    private func addNote() {
        guard let pdfView = pdfView,
              let selection = pdfView.currentSelection else { return }

        // Create a text annotation at the first line’s rectangle
        if let page = selection.pages.first {
            let lineRect = selection.bounds(for: page)
            let note = PDFAnnotation(bounds: lineRect, forType: .text, withProperties: nil)
            note.color = .orange
            note.contents = "💡 Note"
            page.addAnnotation(note)
        }
    }
}
