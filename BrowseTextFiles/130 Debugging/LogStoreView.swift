//
//  LogStoreView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 4/11/26.
//

import SwiftUI

struct LogStoreView: View {
    var body: some View {
        let store = LogStore.shared
        ScrollViewReader { proxy in
            ZStack(alignment: .topTrailing) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(store.logs) { log in
                            Text(log.description)
                        }
                        Text("").id("999")
                    }
                    .monospaced()
                    .padding(.horizontal)
                }
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                HStack {
                    Button("Scroll Down") {
                        proxy.scrollTo("999")
                    }
                    .padding(.horizontal)
                }
            }
            .frame(minWidth: 450, minHeight: 150)
        }
        .background(WindowAccessor(onResolve: setupWindow))
    }

    func setupWindow(_ window: NSWindow?) {
        guard let window else { return }
        window.collectionBehavior.insert(.ignoresCycle)
    }
}
