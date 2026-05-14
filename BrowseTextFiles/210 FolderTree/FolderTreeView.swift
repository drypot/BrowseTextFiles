//
//  FolderTreeView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI
import MyLibrary

struct FolderTreeView: View {
    @Environment(AppState.self) var appState
    @Environment(FileBrowserState.self) var state
    @Environment(\.appearsActive) var appearsActive

    @FocusState private var isFocused: Bool

    var body: some View {
        let isActive = appearsActive && isFocused

        List {
            if let rootFolder = state.rootFolder {
                RowView(item: rootFolder, level: 0, isActive: isActive, state: state, appState: appState)
            }
        }
        .focused($isFocused)
        .onKeyPress(.downArrow) {
            if state.moveSelectedFolderDown() {
                state.updateFileListFromSelectedFolder()
            }
            return .handled
        }
        .onKeyPress(.upArrow) {
            if state.moveSelectedFolderUp() {
                state.updateFileListFromSelectedFolder()
            }
            return .handled
        }
        .onKeyPress(.rightArrow) {
            state.expandSelectedFolder()
            return .handled
        }
        .onKeyPress(.leftArrow) {
            if state.collapseSelectedFolder() {
                state.updateFileListFromSelectedFolder()
            }
            return .handled
        }
    }
}

fileprivate struct RowView: View {
    @Environment(\.openWindow) private var openWindow
    
    let item: FolderItem
    let level: Int
    let isActive: Bool
    let state: FileBrowserState
    let appState: AppState

    var body: some View {
        let isExpanded = item.hasChildren && state.isFolderExpanded(for: item.url)

        HStack(spacing: 2) {
            Spacer()
                .frame(width: 9 * CGFloat(level))

            Chevron(hasChildren: item.hasChildren, isExpaned: isExpanded) {
                state.toggleFolder(for: item.url)
            }

            Text(item.name)
                .lineLimit(1)
            
            Spacer()
        }
        .foregroundStyle(foregroundStyle)
        .listRowSeparator(.hidden)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundStyle)
                .padding(.horizontal, 10)
        )
        .frame(maxWidth: .infinity)
        .focusable()
        .focusEffectDisabled() // 포커스 테두리 표시 안 함
        .contentShape(Rectangle()) // 빈공간도 클릭되게 한다.
        .onTapGesture {
            state.selectedFolderID = item.id
            state.updateFileListFromSelectedFolder()
        }
        .contextMenu {
            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromRootURL: item.url, fileURL: nil, openWindow: openWindow)
            }
            Divider()
            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }
        }

        if let children = item.children, isExpanded {
            ForEach(children) { child in
                RowView(item: child, level: level + 1, isActive: isActive, state: state, appState: appState)
            }
        }
    }

    var isSelected: Bool {
        item.id == state.selectedFolderID
    }

    var foregroundStyle: Color {
        if isSelected {
            if isActive {
                Color(nsColor: .selectedMenuItemTextColor)
            } else {
                Color(nsColor: .secondaryLabelColor)
            }
        } else {
            Color(nsColor: .secondaryLabelColor)
        }
    }

    var backgroundStyle: Color {
        if isSelected {
            if isActive {
                Color(nsColor: .selectedContentBackgroundColor)
            } else {
                Color(nsColor: .unemphasizedSelectedContentBackgroundColor)
            }
        } else {
            Color(nsColor: .clear)
        }
    }
}

#Preview {
//    FolderTreeView()
}
