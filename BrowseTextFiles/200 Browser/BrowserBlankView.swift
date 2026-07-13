//
//  BrowserBlankView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserBlankView: View {
    @Environment(AppState.self) var appState
    @Environment(RootState.self) var rootState

    var body: some View {
        Button("Open Folder") {
            showOpenPanel()
        }
    }

    private func showOpenPanel() {
        guard let window = rootState.browserState.window else { return }
        appState.showFolderOpenPanelFor(window) { url in
            rootState.configure(with: url, appState: appState)
            appState.addRecentDocumentURL(url)
        }
    }
}

#Preview {
    BrowserBlankView()
}
