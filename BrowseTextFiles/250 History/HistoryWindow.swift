//
//  HistoryWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/25/26.
//

import SwiftUI

struct HistoryWindow: Scene {
    @Environment(AppState.self) var app

    var body: some Scene {
        WindowGroup("History", id: "history", for: UUID.self) { $id in
            if let browser = app.lastBrowser {
                HistoryContainer()
                    .frame(minWidth: 320, minHeight: 200)
                    .environment(browser)
                    .environment(browser.context)
                    .environment(browser.history)
            }
        }
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { proxy, context in
            app.makeWindowPlacement(
                for: "history",
                uuid: app.lastBrowser?.context.id,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 400, height: 600)
            )
        }
    }
}
