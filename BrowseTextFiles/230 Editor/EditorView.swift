//
//  EditorView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct EditorView: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var browserState
    @Environment(FileListState.self) var fileListState
    @Environment(EditorState.self) var editorState

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            if let loadingError = editorState.loadingError {
                errorMessageView(message: loadingError)
            } else if editorState.containsFile {
                textEditorView()
                    .ignoresSafeArea()
            }
        }
        .onChange(of: fileListState.selectedFileIDs, initial: true) {
            selectedFileIDsChanged()
        }
        .toolbar {
            // ToolbarItemGroup(placement: .navigation) {
            //     Button("Prev", systemImage: "chevron.left")  {
            //     }
            //     .help("이전 항목으로 이동")

            //     Button("Next", systemImage: "chevron.right") {
            //     }
            //     .help("다음 항목으로 이동")
            // }

            ToolbarItemGroup(placement: .secondaryAction) {
                Button("Reload", systemImage: "arrow.clockwise") {
                    browserState.reloadAll()
                }
                .help("Reload")

                Button("New File", systemImage: "square.and.pencil") {
                    browserState.makeNewFile()
                }
                .help("New File")

                Button("New File...", systemImage: "bubble.and.pencil") {
                    browserState.showNewFileSheet()
                }
                .help("New File...")

                Button("Show History", systemImage: "clock") {
                    appState.toggleHistoryWindow(for: browserState, openWindow: openWindow, dismissWindow: dismissWindow)
                }
                .help("Show History")
            }

            ToolbarItem(placement: .primaryAction) {
                Button("Search", systemImage: "magnifyingglass") {
                    appState.toggleSearchWindow(for: browserState, openWindow: openWindow, dismissWindow: dismissWindow)
                }
                .help("Search")
            }
        }
    }

    func errorMessageView(message: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(message)
                .textSelection(.enabled)
            Button("Reload folder tree") {
                browserState.reloadAll()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    func textEditorView() -> some View {
        // SwiftUI TextEditor source of truth 동기화 비효율이 심해서
        // TextViewRepresentable 를 만들었다. NSTextView.string 을 source 로 쓴다.
        TextViewRepresentable(appState: appState, editorState: editorState)
            //.frame(maxWidth: .infinity, maxHeight: .infinity)
            .focused($isFocused)
            .onChange(of: editorState.shouldFocusedCount) {
                isFocused = true
            }
            // TextViewRepresentable.updateNSView 에서 스타일까지 업데이트하면 비효율이 심해진다.
            // 여기로 따로 빼놨다.
            .onChange(of: editorState.updateTextViewStyleCount, initial: true) {
                // 새 파일 로드하면 가끔 스타일이 입혀지지 않아서;
                // 로드된 후 스타일을 강제로 한번 입히는 것으로;
                updateTextViewStyle()
            }
            .onChange(of: appState.fontName) {
                updateTextViewStyle()
            }
            .onChange(of: appState.fontSize) {
                updateTextViewStyle()
            }
            .onChange(of: appState.lineSpacing) {
                updateTextViewStyle()
            }

            // .overlay(
            //     Text(debugID.uuidString.prefix(4))
            //         .font(.caption)
            //         .foregroundColor(.red),
            //     alignment: .topTrailing
            // )
    }

    func updateTextViewStyle() {
        guard let textView = editorState.textView else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        // lineSpacing 쓰면 엔터 입력시 커서가 사라진다; macOS 26
        // paragraphStyle.lineSpacing = appState.lineSpacing
        paragraphStyle.lineHeightMultiple = appState.lineHeightMultiple

        let attributes: [NSAttributedString.Key: Any] = [
            .font: appState.makeNSFont(),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: NSColor.textColor, // dark mode 대응
            //.backgroundColor: NSColor.textBackgroundColor // dark mode 대응
        ]

        textView.typingAttributes = attributes

        guard let storage = textView.textStorage else { return }
        let range = NSRange(
            location: 0,
            length: storage.length
            // length: textView.string.utf16.count
        )
        storage.beginEditing()
        storage.setAttributes(attributes, range: range)
        storage.endEditing()
    }

    func selectedFileIDsChanged() {
        let selectedFileIDs = fileListState.selectedFileIDs
        if selectedFileIDs.count == 0 {
            editorState.reset()
            return
        }
        if selectedFileIDs.count == 1 {
            guard let url = selectedFileIDs.first else { return }
            editorState.loadFile(at: url)
            browserState.historyState.addToHistory(url)
        }
    }
}
