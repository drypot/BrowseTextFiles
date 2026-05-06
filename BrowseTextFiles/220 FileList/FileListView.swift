//
//  FileListView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/03/26.
//

import SwiftUI
import MyLibrary

struct FileListView: View {
    @Environment(\.controlActiveState) var controlActiveState
    @FocusState private var isFocused: Bool

    let status: FileBrowserStatus

    var body: some View {
        let isActive = controlActiveState != .inactive && isFocused

        List {
            if let fileList = status.fileList {
                ForEach(fileList) { fileItem in
                    RowView(item: fileItem, isActive: isActive, status: status)
                }
            }
        }
        .focused($isFocused)
        .onKeyPress(.downArrow) {
            if status.moveSelectedFileDown() {
                status.updateFileBufferFromSelectedFile()
            }
            return .handled
        }
        .onKeyPress(.upArrow) {
            if status.moveSelectedFileUp() {
                status.updateFileBufferFromSelectedFile()
            }
            return .handled
        }
    }
}

fileprivate struct RowView: View {
    let item: FileItem
    let isActive: Bool
    let status: FileBrowserStatus

    var isSelected: Bool {
        item == status.selectedFile
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
            status.updateSelectedFile(to: item)
            status.updateFileBufferFromSelectedFile()
        }
        .contextMenu {
            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }
        }
    }
}

#Preview {
//    FileListView()
}
