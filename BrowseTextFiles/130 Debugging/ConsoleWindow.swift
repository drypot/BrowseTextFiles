//
//  ConsoleWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/19/26.
//

import SwiftUI
import MyLibrary

struct ConsoleWindow: Scene {
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        Window("Debugging Console", id: "console") {
            LogStoreView()
                .padding()
                .frame(minWidth: 150, minHeight: 150)
        }
        .commands {
            CommandGroup(after: .help) {
                Button("Debugging Console") {
                    openWindow(id: "console")
                }
                .keyboardShortcut("c", modifiers: [.command, .option])
            }
        }
    }
}

#Preview {
//    ConsoneWindow()
}
