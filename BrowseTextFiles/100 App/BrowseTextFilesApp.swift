//
//  BrowseTextFilesApp.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

@main
struct BrowseTextFilesApp: App {

    @State private var appState = AppState()

    var body: some Scene {
        BrowserWindow()
            .environment(appState)

        SearchWindow()
            .environment(appState)

        AboutWindow()
            //.environment(appState)

        SettingsWindow()
            .environment(appState)

        ConsoleWindow()
            //.environment(appState)
    }
}
