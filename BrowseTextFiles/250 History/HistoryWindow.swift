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
            if let stateRoot = appState.lastRootState {
                HistoryContainer()
                    .frame(minWidth: 320, minHeight: 200)
                    .environment(stateRoot)
                    .environment(stateRoot.browserState)
                    .environment(stateRoot.browserState)
                    .environment(stateRoot.historyState)
            }
        }
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { proxy, context in
            appState.makeWindowPlacement(
                for: "history",
                uuid: appState.lastRootState?.browserState.id,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 400, height: 600)
            )
        }
    }
}
