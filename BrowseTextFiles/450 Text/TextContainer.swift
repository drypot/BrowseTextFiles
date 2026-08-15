//
//  TextContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct TextContainer: View {
    @Environment(BrowserState.self) var browser

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack {
            if browser.text.hasLoadingError {
                TextError()
            } else if browser.text.fileAssigned {
                // SwiftUI TextEditor source of truth 동기화 비효율이 심해서
                // TextViewRepresentable 를 만들었다. NSTextView.string 을 source 로 쓴다.
                TextViewRepresentable()
                    .ignoresSafeArea()
                    .modifier(TextFocus())
                    .modifier(TextStyle())
            }
        }
        .onChange(of: browser.context.selectedFileURL, initial: true) { _, url in
            if let url {
                browser.text.loadFile(at: url)
                browser.history.addToHistory(url)
            } else {
                browser.text.reset()
            }
        }
    }
}
