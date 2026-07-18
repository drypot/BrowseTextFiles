//
//  SearchWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct SearchWindow: Scene {
    @Environment(AppState.self) var appState

    var body: some Scene {
        WindowGroup("Search", id: "search", for: UUID.self) { $id in
            if let stateRoot = appState.lastRootState {
                SearchContainer()
                    .frame(minWidth: 320, minHeight: 200)
                    .environment(stateRoot)
                    .environment(stateRoot.browserState)
                    .environment(stateRoot.browserState)
                    .environment(stateRoot.searchState)
            }
        }
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { proxy, context in
            appState.makeWindowPlacement(
                for: "search",
                uuid: appState.lastRootState?.browserState.id,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 400, height: 600)
            )
        }
    }
}
