//
//  SettingsWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct SettingsWindow: Scene {
    let appState: AppState

    var body: some Scene {
        Settings {
            SettingsView(appState: appState)
        }
    }
}

#Preview {
    // SettingsWindow()
}
