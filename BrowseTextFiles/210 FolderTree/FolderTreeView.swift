//
//  FolderTreeView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI
import MyLibrary

struct FolderTreeView: View {
    @Environment(\.controlActiveState) var controlActiveState
    @FocusState private var isFocused: Bool

    let status: FileBrowserStatus

    var body: some View {
        let isActive = controlActiveState != .inactive && isFocused
        
        List {
            if let rootFolder = status.rootFolder {
                RowView(item: rootFolder, level: 0, isActive: isActive, status: status, )
            }
        }
        .focused($isFocused)
        .onKeyPress(.downArrow) {
            if status.moveSelectedFolderDown() {
                status.updateFileListFromSelectedFolder()
            }
            return .handled
        }
        .onKeyPress(.upArrow) {
            if status.moveSelectedFolderUp() {
                status.updateFileListFromSelectedFolder()
            }
            return .handled
        }
        .onKeyPress(.rightArrow) {
            status.expandSelectedFolder()
            return .handled
        }
        .onKeyPress(.leftArrow) {
            if status.collapseSelectedFolder() {
                status.updateFileListFromSelectedFolder()
            }
            return .handled
        }
    }
}

fileprivate struct RowView: View {
    @Environment(\.openWindow) private var openWindow
    
    let item: FolderItem
    let level: Int
    let isActive: Bool
    let status: FileBrowserStatus

    var isSelected: Bool {
        item == status.selectedFolder
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
        let isExpanded = item.hasChildren && status.isFolderExpanded(for: item.url)

        HStack(spacing: 2) {
            Spacer()
                .frame(width: 9 * CGFloat(level))

            Chevron(hasChildren: item.hasChildren, isExpaned: isExpanded) {
                status.toggleFolder(for: item.url)
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
        .focusable()
        .focusEffectDisabled() // 포커스 테두리 표시 안 함
        .contentShape(Rectangle()) // 빈공간도 클릭되게 한다.
        .onTapGesture {
            status.updateSelectedFolder(to: item)
            status.updateFileListFromSelectedFolder()
        }
        .contextMenu {
            Button("Open in New Tab") {
                let initParam = FileBrowserView.InitParam(rootURL: item.url, fileURL: nil)
                openWindow(id: "browser", value: initParam)
            }
            Divider()
            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }
        }

        if let children = item.children, isExpanded {
            ForEach(children) { child in
                RowView(item: child, level: level + 1, isActive: isActive, status: status)
            }
        }
    }
}

#Preview {
//    FolderTreeView()
}
