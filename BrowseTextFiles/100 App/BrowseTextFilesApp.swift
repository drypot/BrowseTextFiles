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
    @FocusedValue(\.performAction) private var performAction
    @State private var settings = SettingsData()

    var body: some Scene {
        WindowGroup("BrowseTextFiles", id: "browser", for: Action.self) { $action in
            TextBufferBrowser(action: action)
                .toolbar(removing: .title)
                .toolbarBackground(.hidden, for: .windowToolbar)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .environment(settings)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open...", systemImage: "arrow.up.right") {
                    if let performAction {
                        performAction(.openFiles)
                    } else {
                        openWindow(id: "browser", value: Action.openFiles)
                    }
                }
                .keyboardShortcut("o", modifiers: .command)

                Button("Open Recent", systemImage: "clock") {
                    performAction?(.openRecent)
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }

            
        }

        Window("About", id: "about") {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
            // let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
            VStack(spacing: 32) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                VStack(spacing: 4) {
                    Text("BrowseTextFiles")
                        .font(.headline)
                    Text("Version " + version)
                }
                VStack(spacing: 4) {
                    Text("Source code")
                    Link("https://github.com/drypot/BrowseTextFiles", destination: URL(string: "https://github.com/drypot/BrowseTextFiles")!)
                }
                VStack(spacing: 4) {
                    Text("Email")
                    Link("drypot@gmail.com", destination: URL(string: "mailto:drypot@gmail.com")!)
                }
                Text("© 2026 Kyuhyun Park")
            }
            .padding(EdgeInsets(top: 48, leading: 24, bottom: 48, trailing: 24))
            .frame(width: 320)
            .containerBackground(.thickMaterial, for: .window)
            .windowMinimizeBehavior(.disabled)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .restorationBehavior(.disabled)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About BrowseGPXFiles", systemImage: "info.circle") {
                    openWindow(id: "about")
                }
            }
        }
        
        Settings {
            SettingsView()
                .environment(settings)
        }
    }
}
