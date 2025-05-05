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

    // bind to the underlying PDFView
    @State private var pdfView: PDFView?
    // title‐editing state
    @State private var isEditingTitle = false
    @State private var draftTitle = ""
    // delay loading the PDF to prevent SwiftUI warnings
    @State private var isReadyToLoad = false
    // which markup tool is active (or nil)
    @State private var activeTool: MarkupType? = nil

    var body: some View {
        VStack(spacing: 16) {
            // ── Top bar ──
            HStack(spacing: 12) {
                // title / edit toggle
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
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text(paper.title)
                        .font(.title2).bold()
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Button {
                        draftTitle = paper.title
                        isEditingTitle = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // ── Annotation tools ──
                HStack(spacing: 8) {
                    ToolButton(icon: "highlighter", tool: .highlight, activeTool: $activeTool)
                    ToolButton(icon: "underline",    tool: .underline, activeTool: $activeTool)
                    ToolButton(icon: "strikethrough",tool: .strikeOut, activeTool: $activeTool)
                }

                Spacer()

                // mark read/unread
                Button {
                    DispatchQueue.main.async { paper.isRead.toggle() }
                } label: {
                    Text(paper.isRead ? "Mark Unread" : "Mark Read")
                }
                .buttonStyle(.bordered)
            }
            .padding([.top, .horizontal])

            Divider()

            // ── PDF area ──
            Group {
                if isReadyToLoad {
                    if let folder = appVM.folderURL {
                        let fullURL = folder.appendingPathComponent(paper.filename)
                        if FileManager.default.fileExists(atPath: fullURL.path),
                           let _ = PDFDocument(url: fullURL)
                        {
                            PDFKitView(
                                url: fullURL,
                                pdfViewRef: $pdfView,
                                activeTool: $activeTool
                            )
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
            // short delay before loading PDF
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isReadyToLoad = true
            }
        }
    }
}

// A small helper view for each markup‐tool button
fileprivate struct ToolButton: View {
    let icon: String
    let tool: MarkupType
    @Binding var activeTool: MarkupType?

    var body: some View {
        Button {
            // toggle on/off
            activeTool = (activeTool == tool ? nil : tool)
        } label: {
            Image(systemName: icon)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(activeTool == tool
                              ? Color.accentColor.opacity(0.25)
                              : Color.gray.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
        .help(toolHelp)
    }

    private var toolHelp: String {
        switch tool {
        case .highlight:  return "Highlight"
        case .underline:  return "Underline"
        case .strikeOut:  return "Strike-through"
        }
    }
}
