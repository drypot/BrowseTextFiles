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
            if let state = appState.popBrowserState(id) {
                SearchView()
                    .environment(state)
            }
        }
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { proxy, context in
            let size = appState.lastSearchWindowSize ?? CGSize(width: 250, height: 600)
            let position: CGPoint?
            if let lastPosition = appState.lastSearchWindowPosition {
                let displayBounds = context.defaultDisplay.visibleRect
                position = CGPoint(
                    x: lastPosition.x,
                    y: displayBounds.maxY - lastPosition.y - size.height)
            } else {
                position = nil
            }
            return WindowPlacement(position, size: size)
        }
    }
}

#Preview {
//    SearchWindow()
}
