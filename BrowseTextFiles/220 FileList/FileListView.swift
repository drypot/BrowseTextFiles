//
//  FileListView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/03/26.
//

import SwiftUI
import MyLibrary

struct FileListView: View {
    @Environment(AppState.self) var appState
    @Environment(FileBrowserState.self) var state
    @Environment(\.controlActiveState) var controlActiveState

    @FocusState private var isFocused: Bool

    var body: some View {
        let isActive = controlActiveState != .inactive && isFocused

        List {
            if let fileList = state.fileList {
                ForEach(fileList) { fileItem in
                    RowView(item: fileItem, isActive: isActive, state: state, appState: appState)
                }
            }
        }
        .focused($isFocused)
        .onKeyPress(.downArrow) {
            if state.moveSelectedFileDown() {
                state.updateFileBufferFromSelectedFile()
            }
            return .handled
        }
        .onKeyPress(.upArrow) {
            if state.moveSelectedFileUp() {
                state.updateFileBufferFromSelectedFile()
            }
            return .handled
        }
    }
}

fileprivate struct RowView: View {
    @Environment(\.openWindow) private var openWindow

    let item: FileItem
    let isActive: Bool
    let state: FileBrowserState
    let appState: AppState

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
        .focusable()
        .focusEffectDisabled() // 포커스 테두리 표시 안 함
        .contentShape(Rectangle()) // 빈공간도 클릭되게 한다.
        .onTapGesture {
            state.updateSelectedFile(to: item)
            state.updateFileBufferFromSelectedFile()
        }
        .contextMenu {
            Button("Open in New Window") {
                appState.openNewBrowserWindow(fromFileURL: item.url, openWindow: openWindow)
            }
            Divider()
            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }
        }
    }

    var isSelected: Bool {
        item == state.selectedFile
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
