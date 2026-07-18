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
            if let state = appState.lastRootState {
                HistoryContainer()
                    .frame(minWidth: 320, minHeight: 200)
                    .environment(state)
                    .environment(state.context)
                    .environment(state.context)
                    .environment(state.history)
            }
        }
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { proxy, context in
            appState.makeWindowPlacement(
                for: "history",
                uuid: appState.lastRootState?.context.id,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 400, height: 600)
            )
        }
    }
}
