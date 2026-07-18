//
//  BrowserBlankView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserBlankView: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var state

    var body: some View {
        Button("Open Folder") {
            showOpenPanel()
        }
    }

    private func showOpenPanel() {
        guard let window = state.context.window else { return }
        appState.showFolderOpenPanelFor(window) { url in
            state.configure(with: url, appState: appState)
            appState.addRecentDocumentURL(url)
        }
    }
}

#Preview {
    BrowserBlankView()
}
