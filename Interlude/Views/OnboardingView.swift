//
//  OnboardingView.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import PDFKit
import SwiftData

struct OnboardingView: View {
    @EnvironmentObject var appVM: AppViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var isImporting = false
    @State private var importFinished = false
    @State private var importCount = 0

    var body: some View {
        if !importFinished {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Image("Logo")
                        .resizable()
                        .frame(width: 120, height: 120)

                    Text("Welcome to Interlude")
                        .font(.title)
                        .multilineTextAlignment(.center)

                    Text("Your personal library for research papers.\nHighlight, organize, and focus.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }

                if isImporting {
                    ProgressView("Importing \(importCount) PDF\(importCount == 1 ? "" : "s")…")
                        .controlSize(.large)
                        .padding()
                } else {
                    Button(action: openFolderPicker) {
                        Label("Select Folder", systemImage: "folder.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.extraLarge)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: importFinished)
        }
    }

    // MARK: - Folder Picker & Import

    private func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"

        if panel.runModal() == .OK, let folderURL = panel.url {
            isImporting = true
            appVM.folderURL = folderURL
            UserDefaults.standard.set(folderURL.path, forKey: "papersFolder")

            DispatchQueue.global(qos: .userInitiated).async {
                importPDFs(from: folderURL)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    importFinished = true
                }
            }
        }
    }

    private func importPDFs(from folder: URL) {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
            return
        }

        for file in files where file.pathExtension.lowercased() == "pdf" {
            importPDF(file)
        }
    }

    private func importPDF(_ url: URL) {
        let filename = url.lastPathComponent
        let title = extractTitle(from: url)

        let fetch = FetchDescriptor<Paper>(predicate: #Predicate { $0.filename == filename })
        if let existing = try? modelContext.fetch(fetch), !existing.isEmpty {
            return
        }

        let paper = Paper(
            title: title,
            filename: filename,
            authors: [],
            tags: [],
            isRead: false
        )

        DispatchQueue.main.async {
            modelContext.insert(paper)
            importCount += 1
        }
    }

    private func extractTitle(from url: URL) -> String {
        guard let doc = PDFDocument(url: url),
              let page = doc.page(at: 0),
              let text = page.string else {
            return url.deletingPathExtension().lastPathComponent
        }

        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let filtered = lines.filter { line in
            let l = line.lowercased()
            return !l.hasPrefix("arxiv:")
                && !l.hasPrefix("doi:")
                && !l.contains("preprint")
                && !l.contains("published in")
                && !l.contains("submitted")
                && line.count > 10
        }

        return filtered.first ?? url.deletingPathExtension().lastPathComponent
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppViewModel())
}
