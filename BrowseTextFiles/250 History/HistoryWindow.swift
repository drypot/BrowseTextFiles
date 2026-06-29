//
//  HistoryWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/25/26.
//

import SwiftUI

struct HistoryWindow: Scene {
    var appState: AppState

    var body: some Scene {
        WindowGroup("History", id: "history", for: UUID.self) { $id in
            if let state = appState.lastBrowserState {
                HistoryView(appState: appState, state: state)
                    .frame(minWidth: 320, minHeight: 200)
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
