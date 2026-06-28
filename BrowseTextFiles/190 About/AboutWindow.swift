//
//  AboutWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/19/26.
//

import SwiftUI

struct AboutWindow: Scene {
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
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
                Button("About Browse Text Files") {
                    openWindow(id: "about")
                }
            }
        }
    }
}

#Preview {
//    AboutScene()
}
