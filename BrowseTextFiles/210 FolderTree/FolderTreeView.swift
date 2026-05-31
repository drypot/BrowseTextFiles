//
//  FolderTreeView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI

struct FolderTreeView: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var state
    @Environment(\.openWindow) private var openWindow
    @Environment(\.appearsActive) var appearsActive
    @Environment(\.focusedViewBinding) var focusedViewBinding

    var body: some View {
        let isActive = appearsActive && (focusedViewBinding?.wrappedValue == .folderTree)

        ScrollViewReader { proxy in
            List {
                if let rootFolder = state.rootFolder {
                    RowView(item: rootFolder, level: 0, isActive: isActive)
                        .id(rootFolder.id)
                }
            }
            .onChange(of: state.selectedFolderID) {
                guard let id = state.selectedFolderID else { return }
                proxy.scrollTo(id)
            }
        }
        .focusable()
        .focusEffectDisabled()
        .focused(focusedViewBinding!, equals: .folderTree)
        .onKeyPress(phases: .down, action: handleKeyPress)
        .contextMenu {
            Button("New File...") {
                state.showNewFileSheet()
            }

            Button("New Folder...") {
                state.makeNewFolder()
            }

            Button("Show in Finder") {
                if let rootURL = state.rootURL {
                    Finder.shared.open(url: rootURL)
                }
            }

            Button("Open in New Window") {
                if let rootURL = state.rootURL {
                    appState.openNewBrowserWindow(fromRootURL: rootURL, fileURL: nil, openWindow: openWindow)
                }
            }
        }
    }

    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        //let isShiftPressed = press.modifiers.contains(.shift)
        //let isCommandPressed = press.modifiers.contains(.command)
        //print("key: \(press.key)")

        switch press.key {
        case .tab:
            guard let fileList = state.fileList else { return .handled }
            focusedViewBinding?.wrappedValue = .fileList
            if state.selectedFileID == nil {
                if let first = fileList.first {
                    state.selectFile(first)
                    state.loadFileBuffer()
                }
            }
        case "\u{19}": // shift tab
            break
        case .downArrow:
            if state.selectNextFolder() {
                state.loadFileList()
            }
        case .upArrow:
            if state.selectPreviousFolder() {
                state.loadFileList()
            }
        case .rightArrow:
            state.expandSelectedFolder()
        case .leftArrow:
            if state.collapseSelectedFolder() {
                state.loadFileList()
            }
        case .return:
            guard let selectedFolder = state.selectedFolder else { return .ignored }
            guard selectedFolder != state.rootFolder else { return .ignored }
            state.showRenameFolderSheet(for: selectedFolder)
        default:
            return .ignored
        }

        return .handled
    }
}

fileprivate struct RowView: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var state
    @Environment(\.openWindow) private var openWindow
    @Environment(\.focusedViewBinding) var focusedViewBinding

    let item: FolderForView
    let level: Int
    let isActive: Bool

    var body: some View {
        let isExpanded = item.hasChildren && state.isFolderExpanded(for: item.url)
        let isSelected = item.id == state.selectedFolderID
        let styler = Styler.shared
        let foregroundStyle = styler.foregroundStyleWhen(selected: isSelected, active: isActive)
        let backgroundStyle = styler.backgroundStyleWhen(selected: isSelected, active: isActive)

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
            focusedViewBinding?.wrappedValue = .folderTree
            guard state.selectedFolderID != item.id else { return }
            state.selectFolder(with: item.id)
            state.loadFileList()
        }
        .contextMenu {
            Button("New File...") {
                state.showNewFileSheet(for: item)
            }

            Button("New Folder...") {
                state.makeNewFolder(in: item)
            }

            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }

            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromRootURL: item.url, fileURL: nil, openWindow: openWindow)
            }

            Divider()

            if item != state.rootFolder {
                Button("Rename") {
                    state.showRenameFolderSheet(for: item)
                }

                Button("Delete") {
                    state.trashFolder(at: item.url)
                }
            }
        }
        //.focusEffectDisabled() // 포커스 테두리 표시 안 함

        if let children = item.children, isExpanded {
            ForEach(children) { child in
                RowView(item: child, level: level + 1, isActive: isActive)
                    .id(child.id)
            }
        }
    }

}

#Preview {
    //    FolderTreeView()
}
