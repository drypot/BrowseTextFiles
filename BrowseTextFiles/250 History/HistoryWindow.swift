//
//  HistoryWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/25/26.
//

import SwiftUI

struct HistoryWindow: Scene {
    @Environment(AppState.self) var appState

    var body: some Scene {
        WindowGroup("History", id: "history", for: UUID.self) { $id in
            if let browserState = appState.lastBrowserState {
                HistoryView()
                    .frame(minWidth: 320, minHeight: 200)
                    .environment(browserState)
            }
        }
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { proxy, context in
            appState.makeWindowPlacement(
                for: "history",
                uuid: appState.lastBrowserState?.id,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 400, height: 600)
            )
        }
    }
}
