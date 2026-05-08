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
        WindowGroup("Search", id: "search", for: UUID.self) { _ in
            Group {
                if let state = appState.currentFileBrowserState {
                    SearchResultView(state: state)
                }
            }
        }
        .restorationBehavior(.disabled)
        .defaultSize(width: 820, height: 460)
        .defaultPosition(.center)
    }
}

#Preview {
//    SearchWindow()
}
