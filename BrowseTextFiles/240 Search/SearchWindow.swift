//
//  SearchWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct SearchWindow: Scene {
    @Environment(AppState.self) var app

    var body: some Scene {
        WindowGroup("Search", id: "search", for: UUID.self) { $id in
            if let browser = app.lastBrowser {
                SearchContainer()
                    .frame(minWidth: 320, minHeight: 200)
                    .environment(browser)
                    .environment(browser.context)
                    .environment(browser.search)
            }
        }
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { proxy, context in
            app.makeWindowPlacement(
                for: "search",
                uuid: app.lastBrowser?.context.id,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 400, height: 600)
            )
        }
    }
}
