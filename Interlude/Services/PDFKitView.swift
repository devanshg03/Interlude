//
//  PDFKitView.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import PDFKit
import AppKit        // NSColor, undoManager

/// Mark‑up tools we expose
enum MarkupType { case highlight, underline, strikeOut }

struct PDFKitView: NSViewRepresentable {
    let url: URL
    @Binding var pdfViewRef: PDFView?
    @Binding var activeTool: MarkupType?

    // ----------------------------------------------------
    // MARK: NSViewRepresentable
    // ----------------------------------------------------
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales        = true
        view.displayMode       = .singlePageContinuous
        view.displayDirection  = .vertical
        view.document          = PDFDocument(url: url)

        // expose to SwiftUI
        DispatchQueue.main.async { pdfViewRef = view }

        // observe text selections
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.selectionChanged(_:)),
            name: .PDFViewSelectionChanged,
            object: view
        )
        return view
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        context.coordinator.activeTool = activeTool
        if nsView.document?.documentURL != url {
            nsView.document = PDFDocument(url: url)
        }
    }

    // ----------------------------------------------------
    // MARK: Coordinator
    // ----------------------------------------------------
    final class Coordinator: NSObject {
        private let parent: PDFKitView
        var activeTool: MarkupType?

        init(_ parent: PDFKitView) {
            self.parent = parent
            self.activeTool = parent.activeTool
        }

        // Main entry‑point every time user changes selection
        @objc func selectionChanged(_ note: Notification) {
            guard
                let pdfView   = note.object as? PDFView,
                let tool      = activeTool,
                let selection = pdfView.currentSelection,
                let document  = pdfView.document,
                let docURL    = document.documentURL,
                docURL == parent.url
            else { return }

            // undo manager from the view’s window
            let undoMgr = pdfView.undoManager
            undoMgr?.beginUndoGrouping()

            var toRemove: [(PDFPage, PDFAnnotation)] = []
            var toAdd:    [(PDFPage, PDFAnnotation)] = []

            for page in selection.pages {
                // break multi‑line selection into single lines
                let lineSels = selection.selectionsByLine()
                    .filter { $0.pages.contains(page) }
                for lineSel in lineSels {
                    let bounds   = lineSel.bounds(for: page)
                    let subtype  = subtype(for: tool)
                    let typeStr  = subtype.rawValue

                    // snapshot to avoid mutating while enumerating
                    let existing = page.annotations
                        .first { $0.type == typeStr && $0.bounds.intersects(bounds) }

                    if let ann = existing {
                        toRemove.append((page, ann))
                    } else {
                        let ann = PDFAnnotation(bounds: bounds,
                                                forType: subtype,
                                                withProperties: nil)
                        ann.color = NSColor.yellow.withAlphaComponent(0.4)
                        toAdd.append((page, ann))
                    }
                }
            }

            // apply removals
            for (page, ann) in toRemove {
                page.removeAnnotation(ann)
                undoMgr?.registerUndo(withTarget: page) { p in
                    p.addAnnotation(ann)
                }
            }
            // apply additions
            for (page, ann) in toAdd {
                page.addAnnotation(ann)
                undoMgr?.registerUndo(withTarget: page) { p in
                    p.removeAnnotation(ann)
                }
            }

            undoMgr?.setActionName(actionName(for: tool))
            undoMgr?.endUndoGrouping()

            // persist on main queue NEXT run‑loop to avoid
            // "publishing changes from view updates"
            DispatchQueue.main.async {
                let ok = docURL.startAccessingSecurityScopedResource()
                defer { if ok { docURL.stopAccessingSecurityScopedResource() } }
                _ = document.write(to: docURL)
            }
        }

        // helpers
        private func subtype(for tool: MarkupType) -> PDFAnnotationSubtype {
            switch tool {
            case .highlight:  return .highlight
            case .underline:  return .underline
            case .strikeOut:  return .strikeOut
            }
        }
        private func actionName(for tool: MarkupType) -> String {
            switch tool {
            case .highlight:  return "Highlight"
            case .underline:  return "Underline"
            case .strikeOut:  return "Strike‑through"
            }
        }
    }
}
