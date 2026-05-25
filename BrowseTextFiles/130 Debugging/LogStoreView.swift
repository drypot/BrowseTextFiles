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
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button("Clear") {
                    store.clear()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(store.logs) { log in
                            Text(log.description)
                                .id(log.id)
                        }
                    }
                    .font(.system(.caption, design: .monospaced))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .frame(minWidth: 450, minHeight: 150, maxHeight: .infinity)
                .onChange(of: store.logs.count) { _, _ in
                    guard let last = store.logs.last else { return }
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}
