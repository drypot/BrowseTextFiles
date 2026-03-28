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
//    @FocusedValue(\.performAction) private var performAction

    @State private var settings = SettingsData()

    var body: some Scene {
        WindowGroup("Browser", id: "browser", for: URL.self) { $root in
            TextBrowser(root)
                .toolbar(removing: .title)
                .toolbarBackground(.hidden, for: .windowToolbar)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .environment(settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open...", systemImage: "arrow.up.right") {
                    openFolder()
                }
                .keyboardShortcut("o", modifiers: .command)

                Menu("Open Recent", systemImage: "clock") {
                    let urls = settings.recentDocumentURLs
                    if urls.isEmpty {
                        Text("No Recent Documents")
                    } else {
                        ForEach(urls, id: \.self) { url in
                            Button(url.lastPathComponent) {
                                openWindow(id: "browser", value: url)
                            }
                        }
                        Divider()
                        Button("Clear Menu") {
                            settings.clearRecentDocuments()
                        }
                    }
                }
            }
        }
        .defaultWindowPlacement { proxy, context in
            let displayBounds = context.defaultDisplay.visibleRect
            let size = CGSize(width: displayBounds.width * 2 / 3, height: displayBounds.height * 2 / 3)

            let position = CGPoint(
                x: displayBounds.midX - (size.width / 2),
                y: displayBounds.maxY - size.height - 140)
            return WindowPlacement(position, size: size)
        }

        Window("About", id: "about") {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
            // let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
            VStack(spacing: 32) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                VStack(spacing: 4) {
                    Text("Browse Text Files")
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
                Button("About Browse Text Files", systemImage: "info.circle") {
                    openWindow(id: "about")
                }
            }
        }
        
        Settings {
            SettingsView()
                .environment(settings)
        }
    }

    func openFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK {
            if let url = panel.url {
                openWindow(id: "browser", value: url)
            }
        }
    }
}
