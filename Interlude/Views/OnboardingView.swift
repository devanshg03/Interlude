//
//  OnboardingView.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appVM: AppViewModel

    var body: some View {
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

            
            Button(action: openFolderPicker) {
                Label("Select Folder", systemImage: "folder.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)


            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 0)
                .fill(.background)
        }
    }

    private func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        panel.title = "Choose Your Papers Folder"

        if let keyWindow = NSApp.keyWindow {
            panel.beginSheetModal(for: keyWindow) { response in
                if response == .OK, let url = panel.url {
                    appVM.folderURL = url
                    UserDefaults.standard.set(url.path, forKey: "papersFolder")
                }
            }
        } else {
            if panel.runModal() == .OK, let url = panel.url {
                appVM.folderURL = url
                UserDefaults.standard.set(url.path, forKey: "papersFolder")
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppViewModel())
}
