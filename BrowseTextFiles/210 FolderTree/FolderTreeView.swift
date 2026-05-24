//
//  FolderTreeView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI

struct FolderTreeView: View {
    @Environment(AppState.self) var appState
    @Environment(FileBrowserState.self) var state
    @Environment(\.appearsActive) var appearsActive
    @Environment(\.focusedBinding) var focusedBinding

    var body: some View {
        let isActive = appearsActive && (focusedBinding?.wrappedValue == .folderTree)

        List {
            if let rootFolder = state.rootFolder {
                RowView(item: rootFolder, level: 0, isActive: isActive)
            }
        }
        .focusable()
        .focusEffectDisabled()
        .focused(focusedBinding!, equals: .folderTree)
        .onKeyPress(phases: .down, action: handleKeyPress)
    }

    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        //let isShiftPressed = press.modifiers.contains(.shift)
        //let isCommandPressed = press.modifiers.contains(.command)
        //print("key: \(press.key)")

        switch press.key {
        case .tab:
            guard let fileList = state.fileList else { return .handled }
            focusedBinding?.wrappedValue = .fileList
            if state.selectedFileID == nil {
                if let first = fileList.first {
                    state.selecteFile(first)
                    state.updateFileBufferFromSelectedFile()
                }
            }
        case "\u{19}": // shift tab
            break
        case .downArrow:
            if state.selecteNextFolder() {
                state.updateFileListFromSelectedFolder()
            }
        case .upArrow:
            if state.selectePreviousFolder() {
                state.updateFileListFromSelectedFolder()
            }
        case .rightArrow:
            state.expandSelectedFolder()
        case .leftArrow:
            if state.collapseSelectedFolder() {
                state.updateFileListFromSelectedFolder()
            }
        case .return:
            guard let selectedFolder = state.selectedFolder else { return .ignored }
            guard selectedFolder != state.rootFolder else { return .ignored }
            state.showRenameFolder(id: selectedFolder.id)
        default:
            return .ignored
        }

        return .handled
    }
}

fileprivate struct RowView: View {
    @Environment(AppState.self) var appState
    @Environment(FileBrowserState.self) var state
    @Environment(\.openWindow) private var openWindow
    @Environment(\.focusedBinding) var focusedBinding

    let item: FolderForView
    let level: Int
    let isActive: Bool

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
        .contentShape(Rectangle()) // 빈공간도 클릭되게 한다.
        .onTapGesture {
            focusedBinding?.wrappedValue = .folderTree
            guard state.selectedFolderID != item.id else { return }
            state.selecteFolder(withID: item.id)
            state.updateFileListFromSelectedFolder()
        }
        .contextMenu {
            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromRootURL: item.url, fileURL: nil, openWindow: openWindow)
            }
            if item != state.rootFolder {
                Button("Rename") {
                    state.showRenameFolder(id: item.id)
                }
            }
            Divider()
            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }
        }
        //.focusEffectDisabled() // 포커스 테두리 표시 안 함

        if let children = item.children, isExpanded {
            ForEach(children) { child in
                RowView(item: child, level: level + 1, isActive: isActive)
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
