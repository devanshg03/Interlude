//
//  SidebarView.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appVM: AppViewModel
    @Query private var papers: [Paper]
    
    private func importPapersFromFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"

        if panel.runModal() == .OK, let folder = panel.url {
            let fileManager = FileManager.default
            if let urls = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                for fileURL in urls where fileURL.pathExtension.lowercased() == "pdf" {
                    importPDF(fileURL)
                }
            }
        }
    }

    private func importPDF(_ fileURL: URL) {
        let filename = fileURL.lastPathComponent
        let title = extractTitle(from: fileURL)

        // Prevent duplicates by filename
        let fetch = FetchDescriptor<Paper>(predicate: #Predicate { $0.filename == filename })
        if let existing = try? modelContext.fetch(fetch), !existing.isEmpty {
            return // skip existing
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


    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            
            Button(action: importPapersFromFolder) {
                Label("Import", systemImage: "tray.and.arrow.down.fill")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .frame(maxWidth: .infinity) // ⬅️ THIS expands the button fully

            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                // Paste section here (✅ this is fine)
                Text("STATUS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)

                Group {
                    statusButton(label: "All", icon: "line.3.horizontal.decrease.circle", selected: appVM.readFilter == .all) {
                        appVM.readFilter = .all
                    }

                    statusButton(label: "Read", icon: "checkmark.circle", selected: appVM.readFilter == .read) {
                        appVM.readFilter = .read
                    }

                    statusButton(label: "Unread", icon: "circle", selected: appVM.readFilter == .unread) {
                        appVM.readFilter = .unread
                    }
                }
                .padding(.horizontal, 4)
            }

            

            Spacer()
        }
        .padding()
        .navigationTitle("Library")
    }
    
    @ViewBuilder
        private func statusButton(label: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .foregroundColor(selected ? .accentColor : .secondary)
                        .frame(width: 20)

                    Text(label)
                        .foregroundColor(selected ? .accentColor : .primary)

                    Spacer()
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(selected ? Color.accentColor.opacity(0.15) : Color.clear)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
}
