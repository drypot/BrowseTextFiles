//
//  FileListView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/03/26.
//

import SwiftUI

struct FileListView: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var browserState
    @Environment(FileListState.self) var fileListState
    @Environment(NewFileState.self) var newFileState
    @Environment(RenameState.self) var renameState

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        @Bindable var fileListState = fileListState
        ScrollViewReader { proxy in
            List(fileListState.fileList ?? [], selection: $fileListState.selectedFileIDs) { file in
                NavigationLink(file.name, value: file.id)
                    .id(file.id)
                    .listRowSeparator(.hidden)
            }
            .onChange(of: fileListState.scrollToFileID) { _, id in
                if let id {
                    proxy.scrollTo(id)
                }
            }
        }
        .onKeyPress(phases: .down, action: handleKeyPress)
        .contextMenu(forSelectionType: FileState.ID.self) { selection in
            Button("New File") {
                browserState.newFileState.makeNewFile()
            }

            Button("New File...") {
                guard let folderURL = browserState.fileListState.folderURL else { return }
                browserState.newFileState.showNewFileSheet(for: folderURL)
            }

            Button("New Folder") {
                browserState.makeNewFolder()
            }

            Button("Show in Finder") {
                browserState.openFinder()
            }

            Button("Open in New Window") {
                fileListState.openNewBrowserWindow(appState: appState, openWindow: openWindow)
            }

            Divider()

            if selection.count == 1 {
                Button("Rename") {
                    showRenameSheet(selection: selection)
                }
            }

            Button("Delete") {
                fileListState.trashFiles(selection: selection)
            }
        }
    }

    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .tab:
            //focusedViewBinding?.wrappedValue = .textEditor
            browserState.editorState.shouldFocusedCount += 1

        case .return:
            showRenameSheet(selection: fileListState.selectedFileIDs)

        /*
        case "\u{19}": // shift tab
            focusedViewBinding?.wrappedValue = .folderTree
        case .downArrow:
            if fileListState.selecteNextFile() {
                browserState.editorState.loadFile(at: fileListState.selectedFile?.url)
            }
        case .upArrow:
            if fileListState.selectePreviousFile() {
                browserState.editorState.loadFile(at: fileListState.selectedFile?.url)
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
            if fileListState.selectedFileIDs.first == oldURL {
                fileListState.reloadFileList(preserveSelection: false)
                fileListState.selectFile(with: newURL)
            } else {
                fileListState.reloadFileList(preserveSelection: true)
            }
        }
    }

    /*
    List 수작업으로 전부 만들었을 때 코드

    var body: some View {
        let isActive = appearsActive && (focusedViewBinding?.wrappedValue == .fileList)

        ScrollViewReader { proxy in
            List {
                if let fileList = fileListState.fileList {
                    ForEach(fileList) { fileItem in
                        RowView(appState: appState, browserState: browserState, item: fileItem, isActive: isActive)
                            .id(fileItem.id)
                    }
                }
            }
            .onChange(of: fileListState.selectedFileID) {
                guard let id = fileListState.selectedFileID else { return }
                proxy.scrollTo(id)
            }
        }
        .focusable()
        .focusEffectDisabled()
        .focused(focusedViewBinding!, equals: .fileList)
        .onKeyPress(phases: .down, action: handleKeyPress)
        .contextMenu {
            menuItems
        }
    }
    */
}

/*
List 수작업으로 전부 만들었을 때 코드

fileprivate struct RowView: View {
    @Environment(\.openWindow) private var openWindow

    var appState: AppState
    var browserState: BrowserState
    var fileListState: FileListState

    let item: FileState
    let isActive: Bool

    init(appState: AppState, browserState: BrowserState, item: FileState, isActive: Bool) {
        self.appState = appState
        self.browserState = browserState
        self.fileListState = browserState.fileListState
        self.item = item
        self.isActive = isActive
    }

    var body: some View {
        let isSelected = item.id == fileListState.selectedFileID
        let styler = Styler.shared
        let foregroundStyle = styler.foregroundStyleWhen(selected: isSelected, active: isActive)
        let backgroundStyle = styler.backgroundStyleWhen(selected: isSelected, active: isActive)
        HStack {
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
            //focusedViewBinding?.wrappedValue = .fileList
            guard fileListState.selectedFileID != item.id else { return }
            fileListState.selectFile(with: item.id)
            //browserState.editorState.loadFile(at: fileListState.selectedFile?.url)
        }
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
                Finder.shared.open(url: item.url)
            }

            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromFileURL: item.url, openWindow: openWindow)
            }

            Divider()

            Button("Rename") {
                browserState.showRenameSheet(for: item.url, isFolder: false)
            }

            Button("Delete") {
                fileListState.trashFile(at: item.url)
            }
        }
        //.focusEffectDisabled() // 포커스 테두리 표시 안 함
    }
}
*/
