//
//  BrowseTextFilesApp.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

@main
struct BrowseTextFilesApp: App {

    @State private var appState = AppState()

    var body: some Scene {
        FileBrowserWindow()
            .environment(appState)

        SearchWindow()
            .environment(appState)

        AboutWindow()

        SettingsWindow()
            .environment(appState)

        ConsoleWindow()
    }
}
