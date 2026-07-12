//
//  FolderTreeView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI

struct FolderTreeView: View {
    @Environment(AppState.self) var appState
    @Environment(RootState.self) var rootState
    @Environment(BrowserState.self) var browserState
    @Environment(FolderTreeState.self) var folderTreeState

    var body: some View {
        @Bindable var browserState = browserState
        @Bindable var folderTreeState = folderTreeState
        ScrollViewReader { proxy in
            List(selection: $browserState.selectedFolderURLs) {
                if let rootFolder = folderTreeState.rootFolder {
                    TreeRow(rootFolder, children: \.children, expanded: $folderTreeState.expandedFolderURLs) { folder in
                        Text(folder.name)
                            .id(folder.id)
                    }
                }
            }
            .id(folderTreeState.refreshCount)
            .onChange(of: browserState.selectedFolderURL) { _, url in
                if let url {
                    withAnimation {
                        proxy.scrollTo(url)
                    }
                }
            }
        }
        .onKeyPress(phases: .down, action: handleKeyPress)
        .contextMenu(forSelectionType: FolderState.ID.self) {
            FolderTreeContextMenu(selection: $0)
        }
        .toolbar {
            ToolbarItem {
                Button("New Folder", systemImage: "folder.badge.plus") {
                    rootState.makeNewFile(in: browserState.selectedFolderURL)
                }
                .help("New Folder")
            }
        }
    }

    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        //let isShiftPressed = press.modifiers.contains(.shift)
        //let isCommandPressed = press.modifiers.contains(.command)
        //print("key: \(press.key)")

        switch press.key {
        case .tab:
            rootState.editorState.shouldFocusedCount += 1

        case .return:
            rootState.showRenameFolderSheet()

        /*
        case "\u{19}": // shift tab
            break
        case .downArrow:
            if rootState.selectNextFolder() {
                rootState.fileListState.loadFileList(at: rootState.selectedFolder?.url)
            }
        case .upArrow:
            if rootState.selectPreviousFolder() {
                rootState.fileListState.loadFileList(at: rootState.selectedFolder?.url)
            }
        case .rightArrow:
            rootState.expandSelectedFolder()
        case .leftArrow:
            if rootState.collapseSelectedFolder() {
                rootState.fileListState.loadFileList(at: rootState.selectedFolder?.url)
            }
        */

        default:
            return .ignored
        }

        return .handled
    }

    

}

/*
fileprivate struct RowView: View {
    var appState: AppState
    var rootState: RootState

    @Environment(\.openWindow) private var openWindow

    let item: FolderState
    let level: Int
    let isActive: Bool

    var body: some View {
        let isExpanded = item.hasChildren && rootState.isExpanded(item)
        let isSelected = item.id == rootState.selectedFolderID
        let styler = Styler.shared
        let foregroundStyle = styler.foregroundStyleWhen(selected: isSelected, active: isActive)
        let backgroundStyle = styler.backgroundStyleWhen(selected: isSelected, active: isActive)

        HStack(spacing: 2) {
            Spacer()
                .frame(width: 9 * CGFloat(level))

            Chevron(hasChildren: item.hasChildren, isExpaned: isExpanded) {
                rootState.toggleExpanded(item)
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
        .gesture(
            TapGesture(count: 1)
                .onEnded {
                    // print("Single Tap")
                    //focusedViewBinding?.wrappedValue = .folderTree
                    guard rootState.selectedFolderID != item.id else { return }
                    rootState.selectFolder(with: item.id)
                    rootState.fileListState.loadFileList(at: rootState.selectedFolder?.url)
                }
                .simultaneously(with: TapGesture(count: 2)
                    .onEnded {
                        //print("Double tap")
                        rootState.toggleExpanded(item)
                    }
                )
        )
        .contextMenu {
            Button("New File") {
                rootState.makeNewFile(in: item.url)
            }

            Button("New File...") {
                rootState.showNewFileSheet(on: item.url)
            }

            Button("New Folder") {
                rootState.makeNewFolder(in: item.url)
            }

            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }

            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromRootURL: item.url, fileURL: nil, openWindow: openWindow)
            }

            Divider()

            if item != rootState.rootFolder {
                Button("Rename") {
                    rootState.renameState.showRenameSheet(for: item.url) { _, _ in }
                }

                Button("Delete") {
                    rootState.trashFolder(at: item.url)
                }
            }
        }

        // onTapGesture 를 두 개 쓰면 싱글 클릭시 딜레이가 발생한다;
        // 위에 처럼 TapGesture 를 두 개 만들고 simultaneously 로 묶는다.
        //.onTapGesture(count: 1) {
        //    focusedViewBinding?.wrappedValue = .folderTree
        //    guard rootState.selectedFolderID != item.id else { return }
        //    rootState.selectFolder(with: item.id)
        //    rootState.loadFileList()
        //}
        //.onTapGesture(count: 2) {
        //    rootState.toggleFolder(for: item.url)
        //}

        //.focusEffectDisabled() // 포커스 테두리 표시 안 함

        if let children = item.children, isExpanded {
            ForEach(children) { child in
                RowView(appState: appState, rootState: rootState, item: child, level: level + 1, isActive: isActive)
                    .id(child.id)
            }
        }
    }

}
*/
