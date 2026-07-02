//
//  FileListView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/03/26.
//

import SwiftUI

struct FileListView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.appearsActive) var appearsActive
    @Environment(\.focusedViewBinding) var focusedViewBinding

    var appState: AppState
    var browserState: BrowserState
    var fileListState: FileListState

    init(appState: AppState, browserState: BrowserState) {
        self.appState = appState
        self.browserState = browserState
        self.fileListState = browserState.fileListState
    }

    var body: some View {
        let isActive = appearsActive && (focusedViewBinding?.wrappedValue == .fileList)

        // List(state.fileURLsForList, id: \.self, selection: state.selectedFileBinding()) { file in
        //     NavigationLink(file.lastPathComponent, value: file)
        // }

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
                if let url = browserState.selectedFolder?.url {
                    Finder.shared.open(url: url)
                }
            }

            Button("Open in New Window") {
                if let url = browserState.selectedFolder?.url {
                    appState.openNewBrowserWindow(fromFileURL: url, openWindow: openWindow)
                }
            }
        }
    }

    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .tab:
            focusedViewBinding?.wrappedValue = .textEditor
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
        case .return:
            guard let file = fileListState.selectedFile else { return .ignored }
            browserState.showRenameSheet(for: file.url, isFolder: false)
        default:
            return .ignored
        }
        return .handled
    }
}

fileprivate struct RowView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.focusedViewBinding) var focusedViewBinding

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
            focusedViewBinding?.wrappedValue = .fileList
            guard fileListState.selectedFileID != item.id else { return }
            fileListState.selectFile(withID: item.id)
            browserState.editorState.loadFile(at: fileListState.selectedFile?.url)
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

#Preview {
//    FileListView()
}
