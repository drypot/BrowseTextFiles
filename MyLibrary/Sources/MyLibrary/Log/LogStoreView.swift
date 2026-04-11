//
//  LogStoreView.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 4/11/26.
//

import SwiftUI

public struct LogStoreView: View {

    public init() {}
    
    public var body: some View {
        let store = LogStore.shared
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(store.logs) { log in
                        Text(log.description)
                            .id(log.id)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .onChange(of: store.logs.count) { _, _ in
                guard let last = store.logs.last else { return }
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
        .toolbar {
            Button("Clear") {
                store.clear()
            }
        }
    }
}
