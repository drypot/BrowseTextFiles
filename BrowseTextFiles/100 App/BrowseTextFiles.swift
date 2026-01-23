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

    @State private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup("Directory Browser", id: "DirectoryBrowser") {
            DirectoryBrowserWindow()
                .environment(settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Directory") {
                    openDirectory()
                }
                .keyboardShortcut("O", modifiers: [.command])
                Button("Open Sample Directory") {
                    openWindow(id: "DirectoryBrowser")
                }
                .keyboardShortcut("O", modifiers: [.command, .shift])
            }
        }
        Settings {
            SettingsView()
                .environment(settings)
        }
    }

    func openDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            if let url = panel.url {
                DirectoryBrowserWindow.urlsToOpen.append(url)
                openWindow(id: "DirectoryBrowser")
            }
        }
    }


}
