//
//  SearchWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct SearchWindow: Scene {
    @Environment(AppState.self) var appState
    @FocusedValue(\.selectedBrowserState) var selectedBrowserState: FileBrowserState?

    var body: some Scene {
        WindowGroup("Search", id: "search", for: UUID.self) { $initParam in
            Text("id 1: \(initParam?.uuidString ?? "unkndown id")")
            Text("id 2: \(selectedBrowserState?.id.uuidString ?? "unknown id")")
            //            FileBrowser(initParam)
            //                .frame(maxWidth: .infinity, maxHeight: .infinity) // 빈 화면에서 drag & drop 받기 위해
        }
        .restorationBehavior(.disabled)
    }
}

#Preview {
//    SearchWindow()
}
