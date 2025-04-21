//
//  LibraryContainerView.swift
//  Interlude
//
//  Created by Devansh Gandhi on 21/4/2025.
//

import SwiftUI
import SwiftData

struct LibraryContainerView: View {
    @EnvironmentObject var appVM: AppViewModel
    @Query private var papers: [Paper]

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } content: {
            PaperListView(
                papers: papers,
                selectedID: $appVM.selectedPaperID,
                selectedTag: appVM.selectedTag,
                readFilter: appVM.readFilter
            )
        } detail: {
            if let selected = papers.first(where: { $0.id == appVM.selectedPaperID }) {
                PaperDetailView(paper: selected)
            } else {
                Text("Select a paper")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            appVM.allPapers = papers
        }
    }
}

#Preview {
    LibraryContainerView()
        .environmentObject(AppViewModel())
}
