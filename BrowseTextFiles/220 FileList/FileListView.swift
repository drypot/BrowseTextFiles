//
//  FileListView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/03/26.
//

import SwiftUI

struct FileListView: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var state
    @Environment(\.openWindow) private var openWindow
    @Environment(\.appearsActive) var appearsActive
    @Environment(\.focusedViewBinding) var focusedViewBinding

    var body: some View {
        let isActive = appearsActive && (focusedViewBinding?.wrappedValue == .fileList)

        ScrollViewReader { proxy in
            List {
                if let fileList = state.fileList {
                    ForEach(fileList) { fileItem in
                        RowView(item: fileItem, isActive: isActive)
                            .id(fileItem.id)
                    }
                }
            }
            .onChange(of: state.selectedFileID) {
                guard let id = state.selectedFileID else { return }
                proxy.scrollTo(id)
            }
        }
        .focusable()
        .focusEffectDisabled()
        .focused(focusedViewBinding!, equals: .fileList)
        .onKeyPress(phases: .down, action: handleKeyPress)
        .contextMenu {
            Button("New File...") {
                state.showNewFileSheet()
            }

            Button("New Folder...") {
                state.makeNewFolder()
            }

            Button("Show in Finder") {
                if let url = state.selectedFolder?.url {
                    Finder.shared.open(url: url)
                }
            }

            Button("Open in New Window") {
                if let url = state.selectedFolder?.url {
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
            if state.selecteNextFile() {
                state.loadFileBuffer()
            }
        case .upArrow:
            if state.selectePreviousFile() {
                state.loadFileBuffer()
            }
        case .return:
            guard let file = state.selectedFile else { return .ignored }
            state.showRenameSheet(for: file.url, isFolder: false)
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

    let item: FileForView
    let isActive: Bool

    var body: some View {
        let isSelected = item.id == state.selectedFileID
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
            guard state.selectedFileID != item.id else { return }
            state.selectFile(withID: item.id)
            state.loadFileBuffer()
        }
        .contextMenu {
            Button("New File...") {
                state.showNewFileSheet()
            }

            Button("New Folder...") {
                state.makeNewFolder()
            }

            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }

            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromFileURL: item.url, openWindow: openWindow)
            }

            Divider()

            Button("Rename") {
                state.showRenameSheet(for: item.url, isFolder: false)
            }

            Button("Delete") {
                state.trashFile(at: item.url)
            }
        }
        //.focusEffectDisabled() // 포커스 테두리 표시 안 함
    }

}

#Preview {
//    FileListView()
}
