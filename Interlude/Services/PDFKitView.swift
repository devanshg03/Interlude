//
//  PDFKitView.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import PDFKit

struct PDFKitView: NSViewRepresentable {
    // The file URL to display
    let url: URL
    // A binding back to the live PDFView instance
    @Binding var pdfViewRef: PDFView?

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical

        // Load document
        if let doc = PDFDocument(url: url) {
            pdfView.document = doc
        }

        // Expose to SwiftUI
        DispatchQueue.main.async {
            self.pdfViewRef = pdfView
        }

        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        // Only reload if the URL changed
        if nsView.document?.documentURL != url {
            nsView.document = PDFDocument(url: url)
        }
    }
}
