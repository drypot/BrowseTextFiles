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

    @State private var settings = SettingsData()

    var body: some Scene {
        WindowGroup("BrowseTextFiles", id: "main") {
            TextBufferBrowser()
                .environment(settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Directory") {
                    openWindow(id: "main")
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
