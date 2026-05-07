//
//  FileBufferView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct FileBufferView: View {
    @Environment(AppState.self) var appState

    @State private var autoSaveTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool

    var state: FileBrowserState

//    private let debugID = UUID()

//    init(state: FileBrowserState) {
//        self.state = state
//        print("FileBufferView re-created")
//    }

    var body: some View {
        Group {
            if state.isShowSearchView {
                SearchResultView(state: state)
            } else if let loadError = state.fileBuffer?.loadingError {
                Text(loadError)
                    .font(.custom(appState.fontName, size: appState.fontSize))
                    .lineSpacing(appState.lineSpacing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else if let fileBuffer = state.fileBuffer {
                //let _ = Self._printChanges()
                TextEditor(
                    text: fileBuffer.textBinding(),
                    // selection: $state.fileBuffer!.selection
                )
                // 애플 공식문서에 나와있는 것인데 효과 없다.
                // .contentMargins(.horizontal, 20.0, for: .scrollContent)

                // .findDisabled(false)
                // .replaceDisabled(false)

                .font(.custom(appState.fontName, size: appState.fontSize))
                .lineSpacing(appState.lineSpacing)
                .onChange(of: fileBuffer.text) {
                    scheduleAutoSave()
                }
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }

                // .overlay(
                //     Text(debugID.uuidString.prefix(4))
                //         .font(.caption)
                //         .foregroundColor(.red),
                //     alignment: .topTrailing
                // )
            } else {
                Spacer()
            }
        }
        // padding 을 주면 find 기능 사용할 때 화면이 반전되면 좌우 흰색이 안 이쁘게 나타난다.
        // 하지만 contentMargins 이 동작하지 않으니 그냥 써야.
        .padding(.horizontal, 16)
        //        .padding(.top, 16)
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
        .layoutPriority(1)
    }

    func scheduleAutoSave() {
        if appState.autoSavePerSeconds == 0 { return }
        autoSaveTask?.cancel()
        autoSaveTask = Task {
            try? await Task.sleep(for: .seconds(appState.autoSavePerSeconds))
            if Task.isCancelled { return }
            state.saveFileIfEdited()
        }
    }
}

#Preview {
    //    FileBufferView()
}
