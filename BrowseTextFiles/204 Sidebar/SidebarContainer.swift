//
//  SidebarContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/14/26.
//

import SwiftUI

struct SidebarContainer: View {
    @Environment(AppState.self) var appState
    @Environment(RootState.self) var rootState
    @Environment(BrowserState.self) var browserState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SidebarTabs(browserState: browserState)
            Divider()
            
            switch browserState.sidebarStatus {
            case .folder:
                FolderTreeContainer()
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
    @Bindable var browserState: BrowserState

    var body: some View {
        Picker("Navigators", selection: $browserState.sidebarStatus) {
            ForEach(BrowserState.SidebarStatus.allCases) { status in
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
