//
//  FolderTreeView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI

struct FolderTreeView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.appearsActive) var appearsActive
    @Environment(\.focusedViewBinding) var focusedViewBinding

    var appState: AppState
    @Bindable var browserState: BrowserState

    var body: some View {
        let isActive = appearsActive && (focusedViewBinding?.wrappedValue == .folderTree)
        ScrollViewReader { proxy in
            List {
                if let rootFolder = browserState.rootFolder {
                    RowView(appState: appState, browserState: browserState, item: rootFolder, level: 0, isActive: isActive)
                        .id(rootFolder.id)
                }
            }
            .id(browserState.rootFolderRefreshID)
            .onAppear {
                scrollToSelection(proxy)
            }
            .onChange(of: browserState.selectedFolderID) {
                scrollToSelection(proxy)
            }
        }
        .focusable()
        .focusEffectDisabled()
        .focused(focusedViewBinding!, equals: .folderTree)
        .onKeyPress(phases: .down, action: handleKeyPress)
        .contextMenu {
            Button("New File") {
                browserState.makeNewFile()
            }

            Button("New File...") {
                browserState.showNewFileSheet()
            }

            Button("New Folder") {
                browserState.makeNewFolder()
            }

            Button("Show in Finder") {
                if let rootURL = browserState.rootURL {
                    Finder.shared.open(url: rootURL)
                }
            }

            Button("Open in New Window") {
                if let rootURL = browserState.rootURL {
                    appState.openNewBrowserWindow(fromRootURL: rootURL, fileURL: nil, openWindow: openWindow)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button("New Folder", systemImage: "folder.badge.plus") {
                    browserState.makeNewFolder()
                }
                .help("New Folder")
            }
        }
    }

    private func scrollToSelection(_ proxy: ScrollViewProxy) {
        guard let id = browserState.selectedFolderID else { return }
        Task {
            withAnimation {
                proxy.scrollTo(id)
            }
        }
    }

    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        //let isShiftPressed = press.modifiers.contains(.shift)
        //let isCommandPressed = press.modifiers.contains(.command)
        //print("key: \(press.key)")

        switch press.key {
        case .tab:
            guard let fileList = browserState.fileListState.fileList else { return .handled }
            focusedViewBinding?.wrappedValue = .fileList
            if browserState.fileListState.selectedFileID == nil {
                if let first = fileList.first {
                    browserState.fileListState.selectFile(first)
                    browserState.editorState.loadFile(at: first.url)
                }
            }
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
        case .return:
            guard let selectedFolder = browserState.selectedFolder else { return .ignored }
            guard selectedFolder != browserState.rootFolder else { return .ignored }
            browserState.showRenameSheet(for: selectedFolder.url, isFolder: true)
        default:
            return .ignored
        }

        return .handled
    }
}

fileprivate struct RowView: View {
    var appState: AppState
    var browserState: BrowserState

    @Environment(\.openWindow) private var openWindow
    @Environment(\.focusedViewBinding) var focusedViewBinding

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
                    focusedViewBinding?.wrappedValue = .folderTree
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
                browserState.makeNewFile()
            }

            Button("New File...") {
                browserState.showNewFileSheet(for: item)
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
                    browserState.showRenameSheet(for: item.url, isFolder: true)
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

#Preview {
    //    FolderTreeView()
}
