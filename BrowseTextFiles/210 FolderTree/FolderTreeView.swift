//
//  FolderTreeView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI

struct FolderTreeView: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var browserState
    @Environment(RootState.self) var rootState
    @Environment(TargetState.self) var targetState
    @Environment(RenameState.self) var renameState
    @Environment(FolderTreeState.self) var folderTreeState

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        @Bindable var targetState = targetState
        @Bindable var folderTreeState = folderTreeState
        ScrollViewReader { proxy in
            List(selection: $targetState.selectedFolderURLs) {
                if let rootFolder = folderTreeState.rootFolder {
                    TreeRow(rootFolder, children: \.children, expanded: $folderTreeState.expandedFolderURLs) { folder in
                        Text(folder.name)
                            .id(folder.id)
                    }
                }
            }
            .id(folderTreeState.refreshCount)
            .onChange(of: targetState.selectedFolderURL) { _, url in
                if let url {
                    withAnimation {
                        proxy.scrollTo(url)
                    }
                }
            }
        }
        .onKeyPress(phases: .down, action: handleKeyPress)
        .contextMenu(forSelectionType: FolderState.ID.self) { selection in
            if selection.count == 1 {
                Button("New File") {
                    guard let url = selection.first else { return }
                    browserState.makeNewFile(in: url)
                }

                Button("New File...") {
                    guard let url = selection.first else { return }
                    browserState.showNewFileSheet(for: url)
                }

                Button("New Folder") {
                    guard let url = selection.first else { return }
                    folderTreeState.makeNewFolder(in: url)
                }

                Button("Show in Finder") {
                    guard let url = selection.first else { return }
                    Finder.shared.open(url: url)
                }

                Button("Open in New Window") {
                    guard let url = selection.first else { return }
                    appState.openNewBrowserWindow(fromRootURL: url, fileURL: nil, openWindow: openWindow)
                }

                Divider()

                Button("Rename") {
                    showRenameSheet(selection: selection)
                }
            }

            Button("Delete") {
                folderTreeState.trashFolders(selection: selection)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("New Folder", systemImage: "folder.badge.plus") {
                    browserState.makeNewFile(in: targetState.selectedFolderURL)
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
            browserState.editorState.shouldFocusedCount += 1

        case .return:
            showRenameSheet(selection: targetState.selectedFolderURLs)

        /*
        case "\u{19}": // shift tab
            break
        case .downArrow:
            if browserState.selectNextFolder() {
                browserState.fileListState.loadFileList(at: browserState.selectedFolder?.url)
            }
        case .upArrow:
            if browserState.selectPreviousFolder() {
                browserState.fileListState.loadFileList(at: browserState.selectedFolder?.url)
            }
        case .rightArrow:
            browserState.expandSelectedFolder()
        case .leftArrow:
            if browserState.collapseSelectedFolder() {
                browserState.fileListState.loadFileList(at: browserState.selectedFolder?.url)
            }
        */

        default:
            return .ignored
        }

        return .handled
    }

    func showRenameSheet(selection: Set<FileState.ID>) {
        guard selection.count == 1 else { return }
        guard let url = selection.first else { return }
        renameState.showRenameSheet(for: url) { oldURL, newURL in
            if targetState.selectedFolderURL == oldURL {
                folderTreeState.reloadFolderTree()
                targetState.selectedFolderURL = newURL
            } else {
                folderTreeState.reloadFolderTree()
            }
        }
    }

}

/*
fileprivate struct RowView: View {
    var appState: AppState
    var browserState: BrowserState

    @Environment(\.openWindow) private var openWindow

    let item: FolderState
    let level: Int
    let isActive: Bool

    var body: some View {
        let isExpanded = item.hasChildren && browserState.isExpanded(item)
        let isSelected = item.id == browserState.selectedFolderID
        let styler = Styler.shared
        let foregroundStyle = styler.foregroundStyleWhen(selected: isSelected, active: isActive)
        let backgroundStyle = styler.backgroundStyleWhen(selected: isSelected, active: isActive)

        HStack(spacing: 2) {
            Spacer()
                .frame(width: 9 * CGFloat(level))

            Chevron(hasChildren: item.hasChildren, isExpaned: isExpanded) {
                browserState.toggleExpanded(item)
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
                    guard browserState.selectedFolderID != item.id else { return }
                    browserState.selectFolder(with: item.id)
                    browserState.fileListState.loadFileList(at: browserState.selectedFolder?.url)
                }
                .simultaneously(with: TapGesture(count: 2)
                    .onEnded {
                        //print("Double tap")
                        browserState.toggleExpanded(item)
                    }
                )
        )
        .contextMenu {
            Button("New File") {
                browserState.makeNewFile(in: item.url)
            }

            Button("New File...") {
                browserState.showNewFileSheet(on: item.url)
            }

            Button("New Folder") {
                browserState.makeNewFolder(in: item.url)
            }

            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }

            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromRootURL: item.url, fileURL: nil, openWindow: openWindow)
            }

            Divider()

            if item != browserState.rootFolder {
                Button("Rename") {
                    browserState.renameState.showRenameSheet(for: item.url) { _, _ in }
                }

                Button("Delete") {
                    browserState.trashFolder(at: item.url)
                }
            }
        }

        // onTapGesture 를 두 개 쓰면 싱글 클릭시 딜레이가 발생한다;
        // 위에 처럼 TapGesture 를 두 개 만들고 simultaneously 로 묶는다.
        //.onTapGesture(count: 1) {
        //    focusedViewBinding?.wrappedValue = .folderTree
        //    guard browserState.selectedFolderID != item.id else { return }
        //    browserState.selectFolder(with: item.id)
        //    browserState.loadFileList()
        //}
        //.onTapGesture(count: 2) {
        //    browserState.toggleFolder(for: item.url)
        //}

        //.focusEffectDisabled() // 포커스 테두리 표시 안 함

        if let children = item.children, isExpanded {
            ForEach(children) { child in
                RowView(appState: appState, browserState: browserState, item: child, level: level + 1, isActive: isActive)
                    .id(child.id)
            }
        }
    }

}
*/
