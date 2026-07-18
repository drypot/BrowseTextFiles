//
//  BrowseTextFilesApp.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

@main
struct BrowseTextFilesApp: App {
    @State private var app = AppState()

    var body: some Scene {
        BrowserWindow()
            .environment(app)

        // SearchWindow()
        //     .environment(app)

        // HistoryWindow()
        //     .environment(app)

        SettingsWindow()
            .environment(app)

        // ConsoleWindow()

        AboutWindow()
    }
}
