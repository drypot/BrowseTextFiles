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
            ForEach(status.fileURLsForList, id: \.self) { url in
                RowView(status: status, item: url, isActive: isActive)
            }
        }
        .focused($isFocused)
        .onKeyPress(.downArrow) {
            status.moveDownSelectedFile()
            return .handled
        }
        .onKeyPress(.upArrow) {
            status.moveUpSelectedFile()
            return .handled
        }
    }
}

fileprivate struct RowView: View {
    let status: FileBrowserStatus
    let item: URL
    let isActive: Bool

    var isSelected: Bool {
        item == status.selectedFileURL
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
            Text(item.lastPathComponent)
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
            status.updateSelectedFileURL(with: item)
        }
        .focusable()
        .focusEffectDisabled() // 포커스 테두리 표시 안 함
    }
}

#Preview {
//    FileListView()
}
