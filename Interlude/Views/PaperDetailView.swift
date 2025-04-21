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

    @State private var isEditingTitle = false
    @State private var draftTitle: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // ───────────── Top Bar ─────────────
            HStack(spacing: 12) {
                if isEditingTitle {
                    TextField("Title", text: $draftTitle)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)
                        .frame(maxWidth: 400)

                    Button {
                        paper.title = draftTitle
                        isEditingTitle = false
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text(paper.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Button {
                        draftTitle = paper.title
                        isEditingTitle = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.plain)
                    .help("Edit Title")
                }

                Spacer()

                Button(paper.isRead ? "Mark Unread" : "Mark Read") {
                    paper.isRead.toggle()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            Divider()

            // ───────────── PDF View ─────────────
            if let folder = appVM.folderURL {
                let fullURL = folder.appendingPathComponent(paper.filename)
                if FileManager.default.fileExists(atPath: fullURL.path) {
                    PDFKitView(url: fullURL)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("❌ PDF not found at:\n\(fullURL.lastPathComponent)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                Text("⚠️ No folder selected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            draftTitle = paper.title
        }
    }
}
