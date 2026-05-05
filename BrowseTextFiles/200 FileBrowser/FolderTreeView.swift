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
                RowView(status: status, item: rootFolder, level: 0, isActive: isActive)
            }
        }
        .focused($isFocused)
        .onKeyPress(.downArrow) {
            status.moveDownSelectedFolder()
            return .handled
        }
        .onKeyPress(.upArrow) {
            status.moveUpSelectedFolder()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            status.expandSelectedFolder()
            return .handled
        }
        .onKeyPress(.leftArrow) {
            status.collapseSelectedFolder()
            return .handled
        }
    }
}

fileprivate struct RowView: View {
    @Environment(\.openWindow) private var openWindow
    
    let status: FileBrowserStatus
    let item: Folder
    let level: Int
    let isActive: Bool

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
        let hasChildren = item.hasChildren
        let isExpanded = hasChildren && status.isFolderExpanded(for: item.url)

        HStack(spacing: 2) {
            Spacer()
                .frame(width: 9 * CGFloat(level))

            Chevron(hasChildren: hasChildren, isExpaned: isExpanded) {
                status.toggleFolder(with: item.url)
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
        }
        .contextMenu {
            Button("Open in New Tab") {
                let initParam = FileBrowser.InitParam(rootURL: item.url, fileURL: nil)
                openWindow(id: "browser", value: initParam)
            }
            Divider()
            Button("Show in Finder") {
                Finder.shared.open(url: item.url)
            }
        }

        if let folders = item.folders, isExpanded {
            ForEach(folders) { child in
                RowView(status: status, item: child, level: level + 1, isActive: isActive)
            }
        }
    }
}

#Preview {
//    FolderTreeView()
}
