//
//  FileListView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/03/26.
//

import SwiftUI

struct FileListView: View {
    @Environment(AppState.self) var appState
    @Environment(FileBrowserState.self) var state
    @Environment(\.appearsActive) var appearsActive
    @Environment(\.focusedBinding) var focusedBinding

    var body: some View {
        let isActive = appearsActive && (focusedBinding?.wrappedValue == .fileList)

        List {
            if let fileList = state.fileList {
                ForEach(fileList) { fileItem in
                    RowView(item: fileItem, isActive: isActive)
                }
            }
        }
        .focusable()
        .focusEffectDisabled()
        .focused(focusedBinding!, equals: .fileList)
        .onKeyPress(.tab, phases: .down) { event in
            if event.modifiers.contains(.shift) {
                focusedBinding?.wrappedValue = .folderTree
            } else {
                focusedBinding?.wrappedValue = .textEditor
            }
            return .handled
        }
        .onKeyPress(.downArrow) {
            if state.selecteNextFile() {
                state.updateFileBufferFromSelectedFile()
            }
            return .handled
        }
        .onKeyPress(.upArrow) {
            if state.selectePreviousFile() {
                state.updateFileBufferFromSelectedFile()
            }
            return .handled
        }
        .onKeyPress(.return) {
            guard let selectedFileID = state.selectedFileID else { return .ignored }
            state.showRenameFile(id: selectedFileID)
            return .handled
        }
    }
}

fileprivate struct RowView: View {
    @Environment(AppState.self) var appState
    @Environment(FileBrowserState.self) var state
    @Environment(\.openWindow) private var openWindow
    @Environment(\.focusedBinding) var focusedBinding

    let item: FileForView
    let isActive: Bool

    var body: some View {
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
            focusedBinding?.wrappedValue = .fileList
            guard state.selectedFileID != item.id else { return }
            state.selecteFile(withID: item.id)
            state.updateFileBufferFromSelectedFile()
        }
        .contextMenu {
            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromFileURL: item.url, openWindow: openWindow)
            }
            Button("Rename") {
                state.showRenameFile(id: item.id)
            }
            Divider()
            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }
        }
        //.focusEffectDisabled() // 포커스 테두리 표시 안 함
    }

    var isSelected: Bool {
        item.id == state.selectedFileID
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
//    FileListView()
}
