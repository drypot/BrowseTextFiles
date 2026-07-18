//
//  FolderListContainer.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/23/26.
//

import SwiftUI

struct FolderListContainer: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var state
    @Environment(BrowserContext.self) var context
    @Environment(FolderListState.self) var folderListState

    var body: some View {
        ScrollViewReader { proxy in
            FolderList()
                .onChange(of: context.selectedFolderURL, initial: true) { _, url in
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
            state.editor.shouldFocusedCount += 1

        case .return:
            state.showRenameFolder()

        default:
            return .ignored
        }

        return .handled
    }

}

struct FolderTreeToolbar: ToolbarContent {
    @Environment(BrowserState.self) var state
    //@Environment(FolderListState.self) var folderListState

    var body: some ToolbarContent {
        ToolbarItem {
            Button("New Folder", systemImage: "folder.badge.plus") {
                state.makeNewFolder()
            }
            .help("New Folder")
        }
    }
}

/*
fileprivate struct RowView: View {
    var appState: AppState
    var state: RootState

    @Environment(\.openWindow) private var openWindow

    let item: FolderState
    let level: Int
    let isActive: Bool

    var body: some View {
        let isExpanded = item.hasChildren && state.isExpanded(item)
        let isSelected = item.id == state.selectedFolderID
        let styler = Styler.shared
        let foregroundStyle = styler.foregroundStyleWhen(selected: isSelected, active: isActive)
        let backgroundStyle = styler.backgroundStyleWhen(selected: isSelected, active: isActive)

        HStack(spacing: 2) {
            Spacer()
                .frame(width: 9 * CGFloat(level))

            Chevron(hasChildren: item.hasChildren, isExpaned: isExpanded) {
                state.toggleExpanded(item)
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
                    guard state.selectedFolderID != item.id else { return }
                    state.selectFolder(with: item.id)
                    state.fileListState.loadFileList(at: state.selectedFolder?.url)
                }
                .simultaneously(with: TapGesture(count: 2)
                    .onEnded {
                        //print("Double tap")
                        state.toggleExpanded(item)
                    }
                )
        )


        // onTapGesture 를 두 개 쓰면 싱글 클릭시 딜레이가 발생한다;
        // 위에 처럼 TapGesture 를 두 개 만들고 simultaneously 로 묶는다.
        //.onTapGesture(count: 1) {
        //    focusedViewBinding?.wrappedValue = .folderTree
        //    guard state.selectedFolderID != item.id else { return }
        //    state.selectFolder(with: item.id)
        //    state.loadFileList()
        //}
        //.onTapGesture(count: 2) {
        //    state.toggleFolder(for: item.url)
        //}

        //.focusEffectDisabled() // 포커스 테두리 표시 안 함

        if let children = item.children, isExpanded {
            ForEach(children) { child in
                RowView(appState: appState, state: state, item: child, level: level + 1, isActive: isActive)
                    .id(child.id)
            }
        }
    }

}
*/
