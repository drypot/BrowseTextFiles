//
//  BrowserContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/11/26.
//

import SwiftUI

struct BrowserContainer: View {
    @Environment(AppState.self) var app

    @State private var browser = BrowserState()

    init() {
        logger.info("init browser container:")
    }

    var body: some View {
        Group {
            switch browser.context.status {
            case .showOpenPanel:
                BrowserBlank()
            case .loading:
                Text("Loading...")
            case .ready:
                BrowserNavigator()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .windowToolbarFullScreenVisibility(.onHover)
        .toolbarBackground(.hidden, for: .windowToolbar)
        //.navigationTitle(browser.context.rootName ?? "Browser")
        .toolbar(removing: .title)
        .toolbar {
            BrowserToolbar()
        }
        .modifier(BrowserSheet())
        .modifier(BrowserNotification())
        .modifier(BrowserInit())
        .focusedSceneValue(browser)
        .environment(browser)
        .environment(browser.context)
        .environment(browser.folderList)
        .environment(browser.fileList)
        .environment(browser.search)
        .environment(browser.history)
        .environment(browser.text)
    }
}

#Preview {
    BrowserContainer()
}
