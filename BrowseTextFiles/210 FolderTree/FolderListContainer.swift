//
//  FolderListContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI

struct FolderListContainer: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserStateRoot.self) var stateRoot
    @Environment(BrowserState.self) var browserState
    @Environment(FolderListState.self) var folderListState

    var body: some View {
        ScrollViewReader { proxy in
            FolderList()
                .onChange(of: browserState.selectedFolderURL, initial: true) { _, url in
                    if let url {
                        withAnimation {
                            proxy.scrollTo(url)
                        }
                    }
                }
                .onKeyPress(phases: .down, action: handleKeyPress)
                .contextMenu(forSelectionType: FolderState.ID.self) {
                    FolderListContextMenu(selection: $0)
                }
                // .toolbar {
                //     FolderTreeToolbar()
                // }
        }

        // Divider()

        // HStack {
        //     Button {
        //         folderListState.makeNewFolder()
        //     } label: {
        //         Image(systemName: "folder.badge.plus")
        //             .font(.title2)
        //     }
        //     .help("New Folder")
        //     .buttonStyle(.plain)
        //     .labelsHidden()
        // }
        // .padding(12)
    }

    func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        //let isShiftPressed = press.modifiers.contains(.shift)
        //let isCommandPressed = press.modifiers.contains(.command)
        //print("key: \(press.key)")

        switch press.key {
        case .tab:
            stateRoot.editorState.shouldFocusedCount += 1

        case .return:
            stateRoot.showRenameFolder()

        default:
            return .ignored
        }

        return .handled
    }

}

struct FolderTreeToolbar: ToolbarContent {
    @Environment(BrowserStateRoot.self) var stateRoot
    //@Environment(FolderListState.self) var folderListState

    var body: some ToolbarContent {
        ToolbarItem {
            Button("New Folder", systemImage: "folder.badge.plus") {
                stateRoot.makeNewFolder()
            }
            .help("New Folder")
        }
    }
}

/*
fileprivate struct RowView: View {
    var appState: AppState
    var stateRoot: RootState

    @Environment(\.openWindow) private var openWindow

    let item: FolderState
    let level: Int
    let isActive: Bool

    var body: some View {
        let isExpanded = item.hasChildren && stateRoot.isExpanded(item)
        let isSelected = item.id == stateRoot.selectedFolderID
        let styler = Styler.shared
        let foregroundStyle = styler.foregroundStyleWhen(selected: isSelected, active: isActive)
        let backgroundStyle = styler.backgroundStyleWhen(selected: isSelected, active: isActive)

        HStack(spacing: 2) {
            Spacer()
                .frame(width: 9 * CGFloat(level))

            Chevron(hasChildren: item.hasChildren, isExpaned: isExpanded) {
                stateRoot.toggleExpanded(item)
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
        .contentShape(Rectangle()) // 빈공간도 클릭되게 한다.
        .gesture(
            TapGesture(count: 1)
                .onEnded {
                    // print("Single Tap")
                    //focusedViewBinding?.wrappedValue = .folderTree
                    guard stateRoot.selectedFolderID != item.id else { return }
                    stateRoot.selectFolder(with: item.id)
                    stateRoot.fileListState.loadFileList(at: stateRoot.selectedFolder?.url)
                }
                .simultaneously(with: TapGesture(count: 2)
                    .onEnded {
                        //print("Double tap")
                        stateRoot.toggleExpanded(item)
                    }
                )
        )


        // onTapGesture 를 두 개 쓰면 싱글 클릭시 딜레이가 발생한다;
        // 위에 처럼 TapGesture 를 두 개 만들고 simultaneously 로 묶는다.
        //.onTapGesture(count: 1) {
        //    focusedViewBinding?.wrappedValue = .folderTree
        //    guard stateRoot.selectedFolderID != item.id else { return }
        //    stateRoot.selectFolder(with: item.id)
        //    stateRoot.loadFileList()
        //}
        //.onTapGesture(count: 2) {
        //    stateRoot.toggleFolder(for: item.url)
        //}

        //.focusEffectDisabled() // 포커스 테두리 표시 안 함

        if let children = item.children, isExpanded {
            ForEach(children) { child in
                RowView(appState: appState, stateRoot: stateRoot, item: child, level: level + 1, isActive: isActive)
                    .id(child.id)
            }
        }
    }

}
*/
