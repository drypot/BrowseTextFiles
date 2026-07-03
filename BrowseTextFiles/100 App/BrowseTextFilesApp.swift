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
        BrowserWindow(appState: appState)
        SearchWindow(appState: appState)
        HistoryWindow(appState: appState)
        SettingsWindow(appState: appState)
        ConsoleWindow()
        AboutWindow()
    }
}
