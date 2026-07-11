//
//  LogStoreView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 4/11/26.
//

import SwiftUI

struct LogStoreView: View {
    var body: some View {
        LogStoreViewList()
            .background(WindowAccessor(onResolve: setupWindow))
    }

    func setupWindow(_ window: NSWindow?) {
        guard let window else { return }
        window.collectionBehavior.insert(.ignoresCycle)
    }
}

fileprivate struct LogStoreViewList: View {
    var body: some View {
        let store = LogStore.shared
        ScrollViewReader { proxy in
            ZStack(alignment: .topTrailing) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(store.logs) { log in
                            Text(log.description)
                                .textSelection(.enabled)
                                .id(log.id)
                        }
                    }
                    .monospaced()
                    .padding(.horizontal)
                }
                .frame(maxWidth:.infinity, maxHeight: .infinity)
            }
            .frame(minWidth: 450, minHeight: 150)
            .onChange(of: store.lastLogID) {
                proxy.scrollTo(store.lastLogID, anchor: .bottom)
            }
        }
    }
}

