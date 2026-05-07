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
    @State private var settings = SettingsData()

    var body: some Scene {
        FileBrowserWindow()
            .environment(settings)

        AboutWindow()

        SettingsWindow()
            .environment(settings)

        ConsoleWindow()
    }
}
