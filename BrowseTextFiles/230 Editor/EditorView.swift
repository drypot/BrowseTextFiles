//
//  EditorView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct EditorView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.focusedViewBinding) var focusedViewBinding

    var appState: AppState
    var browserState: BrowserState

//    private let debugID = UUID()
    
    var body: some View {
        VStack(alignment: .leading) {
            if let message = browserState.editorState?.loadingError {
                errorMessageView(message: message)
            } else {
                textEditorView
            }
        }
        .ignoresSafeArea()
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
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    var textEditorView: some View {
        // SwiftUI TextEditor source of truth 동기화 비효율이 심해서
        // TextViewRepresentable 를 만들었다. NSTextView.string 을 source 로 쓴다.

        if let editorState = browserState.editorState {
            TextViewRepresentable(appState: appState, editorState: editorState)
            //.frame(maxWidth: .infinity, maxHeight: .infinity)
                .focused(focusedViewBinding!, equals: .textEditor)
                .task {
                    updateTextViewStyle()
                }

            // TextViewRepresentable.updateNSView 에서 스타일까지 업데이트하면 비효율이 심해진다.
            // 여기로 따로 빼놨다.
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
    }

    func updateTextViewStyle() {
        guard let textView = browserState.editorState?.textView else { return }

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
}

#Preview {
    //    EditorView()
}
