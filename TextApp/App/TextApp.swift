//
//  TextApp.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

@main
struct TextApp: App {
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup("Directory Browser", id: "DirectoryBrowser") {
            DirectoryBrowserWindow()
        }
        .commands {
            CommandMenu("File") {
                Button("New Browser Window") {
                    openWindow(id: "DirectoryBrowser")
                }
                .keyboardShortcut("N", modifiers: [.command])
            }
        }
    }
}
