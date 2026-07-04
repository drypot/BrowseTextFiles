//
//  LogStoreView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 4/11/26.
//

import SwiftUI

struct LogStoreView: View {

    init() {}
    
    var body: some View {
        let store = LogStore.shared
        ScrollViewReader { proxy in
            ZStack {
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
                .frame(maxHeight: .infinity)
                HStack {
                    Button("Scroll Down") {
                        proxy.scrollTo("999")
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            .frame(minWidth: 450, minHeight: 150)
        }
        .background(WindowReader(onResolve: setupWindow))
    }

    func setupWindow(_ window: NSWindow?) {
        guard let window else { return }
        window.collectionBehavior.insert(.ignoresCycle)
    }
}
