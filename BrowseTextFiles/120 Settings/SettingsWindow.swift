//
//  SettingsWindow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/7/26.
//

import SwiftUI

struct SettingsWindow: Scene {
    @Environment(SettingsData.self) var settings

    var body: some Scene {
        Settings {
            SettingsView()
                .environment(settings)
        }
    }
}

#Preview {
    // SettingsWindow()
}
