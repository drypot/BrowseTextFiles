//
//  BrowseTextFiles.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

@main
struct BrowseTextFiles: App {
    @Environment(\.openWindow) private var openWindow

    @State private var settings = SettingsModel.load()
    
    var body: some Scene {
        WindowGroup("Directory Browser", id: "DirectoryBrowser") {
            DirectoryBrowserWindow()
                .environment(settings)
        }
        .commands {
            CommandMenu("File") {
                Button("New Browser Window") {
                    openWindow(id: "DirectoryBrowser")
                }
                .keyboardShortcut("N", modifiers: [.command])
            }
        }
        Settings {
            SettingsView(settings: settings)
        }
    }
}
