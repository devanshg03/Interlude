//
//  FolderWatcher.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import Foundation

final class FolderWatcher {
    private var source: DispatchSourceFileSystemObject?
    let monitoredURL: URL
    private let onPDFDetected: (URL) -> Void

    init(folderURL: URL, onPDFDetected: @escaping (URL) -> Void) {
        self.monitoredURL = folderURL
        self.onPDFDetected = onPDFDetected
        print("👀 Starting FolderWatcher for: \(monitoredURL.path)")
        startWatching()
    }

    private func startWatching() {
        let fileDescriptor = open(monitoredURL.path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("❌ Failed to open folder: \(monitoredURL.path)")
            return
        }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: DispatchQueue.main
        )

        source?.setEventHandler { [weak self] in
            self?.scanFolderForPDFs()
        }

        source?.setCancelHandler {
            close(fileDescriptor)
        }

        source?.resume()
        scanFolderForPDFs()
    }

    private func scanFolderForPDFs() {
        let fileManager = FileManager.default
        print("📂 Scanning folder: \(monitoredURL.path)")
        guard let contents = try? fileManager.contentsOfDirectory(at: monitoredURL, includingPropertiesForKeys: nil) else {
            print("❌ Could not read contents of folder")
            return
        }

        for file in contents {
            print("🔍 Found file: \(file.lastPathComponent)")
            if file.pathExtension.lowercased() == "pdf" {
                print("✅ Detected PDF: \(file.lastPathComponent)")
                onPDFDetected(file)
            }
        }
    }

    deinit {
        source?.cancel()
        print("🛑 FolderWatcher stopped for: \(monitoredURL.path)")
    }
}

