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
        .modifier(BrowserToolbar())
        .modifier(BrowserSheet())
        .modifier(BrowserWindowEvent())
        .modifier(BrowserInit())
        .environment(browser)
        .environment(browser.context)
        .environment(browser.folderList)
        .environment(browser.fileList)
        .environment(browser.search)
        .environment(browser.history)
        .environment(browser.text)
        .focusedSceneValue(browser)
    }
}

#Preview {
    BrowserContainer()
}
