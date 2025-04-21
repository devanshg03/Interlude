//
//  ContentView.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import SwiftData
import AppKit
import PDFKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var papers: [Paper]
    @State private var folderWatcher: FolderWatcher?
    @State private var selectedPaper: Paper?
    
    // Metadata editing state
    @State private var metadataTitle = ""
    @State private var metadataAuthors = ""
    @State private var metadataTags = ""
    
    var body: some View {
        NavigationSplitView {
            // Sidebar: list of papers
            List(papers, selection: $selectedPaper) { paper in
                HStack {
                    Text(paper.title.isEmpty ? "Unknown Title" : paper.title)
                        .font(.headline)
                    Spacer()
                    if paper.isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .tag(paper)
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: pickFolder) {
                        Label("Select Folder", systemImage: "folder")
                    }
                }
            }
        } detail: {
            // Detail: PDF + metadata editor + mark-as-read
            if let paper = selectedPaper {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // PDF Preview
                        if let url = pdfURL(for: paper.filename),
                           FileManager.default.fileExists(atPath: url.path) {
                            PDFKitView(url: url)
                                .frame(minHeight: 300)
                                .cornerRadius(8)
                                .shadow(radius: 4)
                        } else {
                            Text("⚠️ PDF not found.")
                                .foregroundColor(.red)
                                .padding(.vertical)
                        }
                        
                        Divider()
                        
                        // Metadata Editor
                        Group {
                            Text("Metadata")
                                .font(.headline)
                            TextField("Title", text: $metadataTitle, prompt: Text("Unknown"))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Authors (comma separated)", text: $metadataAuthors, prompt: Text("Unknown"))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Tags (comma separated)", text: $metadataTags, prompt: Text("Unknown"))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Save Metadata") {
                                saveMetadata(for: paper)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        Divider()
                        
                        // Mark as Read
                        if !paper.isRead {
                            Button("Mark as Read") {
                                markPaperAsRead(paper)
                            }
                            .buttonStyle(.bordered)
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Already Read")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    loadMetadata(from: paper)
                }
                .onChange(of: selectedPaper) { new in
                    if let new = new {
                        loadMetadata(from: new)
                    }
                }
            } else {
                Text("Select a paper")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Folder Selection & Import
    
    private func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        panel.title = "Choose Your Papers Folder"
        
        if panel.runModal() == .OK, let url = panel.url {
            folderWatcher = FolderWatcher(folderURL: url) { fileURL in
                importPDF(fileURL)
            }
        }
    }
    
    private func importPDF(_ fileURL: URL) {
        let filename = fileURL.lastPathComponent
        let title = fileURL.deletingPathExtension().lastPathComponent
        
        guard !papers.contains(where: { $0.filename == filename }) else {
            return
        }
        let newPaper = Paper(
            title: title,
            filename: filename,
            authors: [],
            tags: [],
            isRead: false
        )
        modelContext.insert(newPaper)
    }
    
    private func pdfURL(for filename: String) -> URL? {
        guard let folder = folderWatcher?.monitoredURL else { return nil }
        return folder.appendingPathComponent(filename)
    }
    
    // MARK: - Metadata Handling
    
    private func loadMetadata(from paper: Paper) {
        metadataTitle = paper.title
        metadataAuthors = paper.authors.joined(separator: ", ")
        metadataTags = paper.tags.joined(separator: ", ")
    }
    
    private func saveMetadata(for paper: Paper) {
        paper.title = metadataTitle
        paper.authors = metadataAuthors
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        paper.tags = metadataTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    // MARK: - Mark as Read
    
    private func markPaperAsRead(_ paper: Paper) {
        paper.isRead = true
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Paper.self, inMemory: true)
}

