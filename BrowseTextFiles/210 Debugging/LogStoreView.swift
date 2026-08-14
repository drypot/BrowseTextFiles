//
//  LogStoreView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 4/11/26.
//

import SwiftUI

struct LogStoreView: View {
    var body: some View {
        LogScrollViewReader()
            .background(WindowAccessor(onResolve: setupWindow))
    }

    func setupWindow(_ window: NSWindow?) {
        guard let window else { return }
        window.collectionBehavior.insert(.ignoresCycle)
    }
}

fileprivate struct LogScrollViewReader: View {
    var body: some View {
        let store = LogStore.shared
        ScrollViewReader { proxy in
            LogScrollView()
                .onChange(of: store.shouldScroll) { _, shouldScroll in
                    guard shouldScroll else { return }
                    Task {
                        proxy.scrollTo(-1, anchor: .bottom)
                        store.shouldScroll = false
                    }
                }
        }
    }
}

fileprivate struct LogScrollView: View {
    var body: some View {
        let store = LogStore.shared
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(store.logs) { log in
                    Text(log.description)
                        .textSelection(.enabled)
                }
                Color.clear
                    .frame(height: 1)
                    .id(-1)
            }
            .monospaced()
            .padding(.horizontal)
        }
        .frame(minWidth: 450, minHeight: 150)
        .frame(maxWidth:.infinity, maxHeight: .infinity)
    }
}

