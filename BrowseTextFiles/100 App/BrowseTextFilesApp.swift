//
//  BrowseTextFilesApp.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

@main
struct MainApp: App {
    @Environment(\.openWindow) private var openWindow

    @State private var bufferManager = FileBufferManager()
    @State private var settings = SettingsModel()

    var body: some Scene {
        WindowGroup("Browse Text Files", id: "MainWindow") {
            SimpleFileBrowser()
                .environment(bufferManager)
                .environment(settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Directory") {
                    openWindow(id: "MainWindow")
                }
                .keyboardShortcut("O", modifiers: [.command])
            }
        }
        Settings {
            SettingsView()
                .environment(settings)
        }
    }

}
