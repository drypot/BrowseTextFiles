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
    @Environment(\.appearsActive) var appearsActive
    @Environment(\.focusedViewBinding) var focusedViewBinding

    var body: some View {
        let isActive = appearsActive && (focusedViewBinding?.wrappedValue == .fileList)

        List {
            if let fileList = state.fileList {
                ForEach(fileList) { fileItem in
                    RowView(item: fileItem, isActive: isActive)
                }
            }
        }
        .focusable()
        .focusEffectDisabled()
        .focused(focusedViewBinding!, equals: .fileList)
        .onKeyPress(phases: .down, action: handleKeyPress)
    }

    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .tab:
            focusedViewBinding?.wrappedValue = .textEditor
        case "\u{19}": // shift tab
            focusedViewBinding?.wrappedValue = .folderTree
        case .downArrow:
            if state.selecteNextFile() {
                state.updateFileBufferFromSelectedFile()
            }
        case .upArrow:
            if state.selectePreviousFile() {
                state.updateFileBufferFromSelectedFile()
            }
        case .return:
            guard let selectedFileID = state.selectedFileID else { return .ignored }
            state.showRenameFile(id: selectedFileID)
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
            state.selecteFile(withID: item.id)
            state.updateFileBufferFromSelectedFile()
        }
        .contextMenu {
            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }
            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromFileURL: item.url, openWindow: openWindow)
            }
            Divider()
            Button("Rename") {
                state.showRenameFile(id: item.id)
            }
        }
        //.focusEffectDisabled() // 포커스 테두리 표시 안 함
    }

}

#Preview {
//    FileListView()
}
