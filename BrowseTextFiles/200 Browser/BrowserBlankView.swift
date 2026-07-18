//
//  BrowserBlankView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserBlankView: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    var body: some View {
        Button("Open Folder") {
            showOpenPanel()
        }
    }

    private func showOpenPanel() {
        guard let window = browser.context.window else { return }
        app.showFolderOpenPanelFor(window) { url in
            browser.configure(with: url, app: app)
            app.addRecentDocumentURL(url)
        }
    }
}

#Preview {
    BrowserBlankView()
}
