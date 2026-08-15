//
//  SidebarContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/14/26.
//

import SwiftUI

struct SidebarContainer: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SidebarTabs(context: browser.context)
            Divider()
            
            switch browser.context.sidebarStatus {
            case .folder:
                FolderListContainer()
            case .history:
                HistoryView()
            case .find:
                SearchView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

fileprivate struct SidebarTabs: View {
    @Bindable var context: BrowserContext

    var body: some View {
        Picker("Navigators", selection: $context.sidebarStatus) {
            ForEach(BrowserContext.SidebarStatus.allCases) { status in
                //Image(systemName: status.imageName)
                Text(status.rawValue)
                    .tag(status)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
        .labelsHidden()
        .padding(.horizontal)
        .padding(.bottom)
    }
}
