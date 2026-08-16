//
//  BrowserBlank.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserBlank: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    var body: some View {
        Button("Open Folder") {
            app.configureBrowserFromDialog(browser: browser)
        }
    }
}

#Preview {
    BrowserBlank()
}
