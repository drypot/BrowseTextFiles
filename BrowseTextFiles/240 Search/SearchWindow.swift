//
//  SearchWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct SearchWindow: Scene {
    var appState: AppState

    var body: some Scene {
        WindowGroup("Search", id: "search", for: UUID.self) { $id in
            if let state = appState.lastBrowserState {
                SearchView(appState: appState, state: state)
                    .frame(minWidth: 320, minHeight: 200)
            }
        }
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { proxy, context in
            appState.makeWindowPlacement(
                for: "search",
                uuid: appState.lastBrowserState?.id,
                visibleRect: context.defaultDisplay.visibleRect,
                defaultSize: CGSize(width: 400, height: 600)
            )
        }
    }
}

#Preview {
//    SearchWindow()
}
