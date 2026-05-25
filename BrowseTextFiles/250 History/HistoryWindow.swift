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
            if let state = appState.popBrowserState(id) {
                HistoryView()
                    .environment(state)
            }
        }
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { proxy, context in
            let size = appState.lastHistoryWindowSize ?? CGSize(width: 250, height: 600)
            return WindowPlacement(size: size)
        }
    }
}
