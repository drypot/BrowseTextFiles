//
//  FileListContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/03/26.
//

import SwiftUI

struct FileListContainer: View {
    @Environment(BrowserState.self) var state
    @Environment(BrowserContext.self) var context
    @Environment(FileListState.self) var fileListState

    var body: some View {
        ScrollViewReader { proxy in
            FileList()
                .onChange(of: context.selectedFileURL) { _, url in
                    guard let url else { return }
                    proxy.scrollTo(url)
                }
                .onChange(of: context.selectedFolderURL, initial: true) {
                    fileListState.loadFileList()
                }
        }
        .onKeyPress(phases: .down) {
            handleKeyPress($0)
        }
        .contextMenu(forSelectionType: FileState.ID.self) {
            FileListContextMenu(selection: $0)
        }
    }

    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .tab:
            state.editor.shouldFocusedCount += 1

        case .return:
            state.showRenameFile()

        default:
            return .ignored
        }

        return .handled
    }

}

/*
List 수작업으로 전부 만들었을 때 코드

fileprivate struct RowView: View {
    var appState: AppState
    var state: RootState
    var fileListState: FileListState

    let item: FileState
    let isActive: Bool

    init(appState: AppState, state: RootState, item: FileState, isActive: Bool) {
        self.appState = appState
        self.state = state
        self.fileListState = state.fileListState
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
            fileListState.selectFile(item.id)
            //state.editor.loadFile(at: fileListState.selectedFile?.url)
        }
        //.focusEffectDisabled() // 포커스 테두리 표시 안 함
    }
}
*/
