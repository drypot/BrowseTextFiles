//
//  FolderTreeView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI
import MyLibrary

struct FolderTreeView: View {
    let status: FileBrowserStatus

    var body: some View {
        List {
            NodeView(folder: status.rootFolder!, level: 0, status: status)
        }
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

fileprivate struct NodeView: View {
    @Environment(\.defaultMinListRowHeight) var rowHeight: CGFloat
    @Environment(\.controlActiveState) var controlActiveState

    var folder: Folder
    var level: Int

    let status: FileBrowserStatus

    var isSelected: Bool {
        status.selectedFolder == folder
    }

    var foregroundStyle: Color {
        if isSelected {
            if controlActiveState == .inactive {
                Color(nsColor: .secondaryLabelColor)
            } else {
                Color(nsColor: .selectedMenuItemTextColor)
            }
        } else {
            Color(nsColor: .secondaryLabelColor)
        }
    }

    var backgroundStyle: Color {
        if isSelected {
            if controlActiveState == .inactive {
                Color(nsColor: .unemphasizedSelectedContentBackgroundColor)
            } else {
                Color(nsColor: .selectedContentBackgroundColor)
            }
        } else {
            Color(nsColor: .clear)
        }
    }

    var body: some View {
        let isFolder = folder.folders != nil
        let isExpanded = status.isFolderExpanded(for: folder.url)

        HStack(spacing: 3) {
            Spacer()
                .frame(width: 9 * CGFloat(level))

            if isFolder {
                let expanded = status.isFolderExpanded(for: folder.url)
                Image(systemName: expanded ? "chevron.down" : "chevron.forward")
                    .resizable() // 크기 조절이 가능하도록 설정
                    .scaledToFit()
                    .bold()
                    .frame(width: 9, height: 9)
                    .onTapGesture {
                        status.toggleFolder(with: folder.url)
                    }
            } else {
                Spacer()
                    .frame(width: 9)
            }

            Text(folder.name)
                .foregroundStyle(foregroundStyle)
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
        .frame(maxHeight: rowHeight)
        .contentShape(Rectangle()) // 빈공간도 클릭되게 한다.
        .onTapGesture {
            status.updateSelectedFolder(to: folder)
        }
        .focusable()
        .focusEffectDisabled() // 포커스 테두리 표시 안 함

        if let folders = folder.folders, isExpanded {
            ForEach(folders) { child in
                NodeView(folder: child, level: level + 1, status: status)
            }
        }
    }
}

#Preview {
//    FolderTreeView()
}
