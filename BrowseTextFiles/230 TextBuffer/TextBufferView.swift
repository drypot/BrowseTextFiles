//
//  TextBufferView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct TextBufferView: View {
    @Environment(AppState.self) var appState
    @Environment(BrowserState.self) var state
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.focusedViewBinding) var focusedViewBinding

//    private let debugID = UUID()
    
    var body: some View {
        VStack(alignment: .leading) {
            if let message = state.textBuffer?.loadingError {
                errorMessageView(message: message)
            } else if state.textBuffer != nil {
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
                    state.reloadAll()
                }
                .help("Reload")

                Button("New File", systemImage: "square.and.pencil") {
                    state.makeNewFile()
                }
                .help("New File")

                Button("New File...", systemImage: "bubble.and.pencil") {
                    state.showNewFileSheet()
                }
                .help("New File...")

                Button("Show History", systemImage: "clock") {
                    appState.toggleHistoryWindow(for: state, openWindow: openWindow, dismissWindow: dismissWindow)
                }
                .help("Show History")
            }

            ToolbarItem(placement: .primaryAction) {
                Button("Search", systemImage: "magnifyingglass") {
                    appState.toggleSearchWindow(for: state, openWindow: openWindow, dismissWindow: dismissWindow)
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
                state.reloadAll()
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    var textEditorView: some View {
        // let _ = Self._printChanges()

        // TextEditor(
        //     text: fileBuffer.textBinding(),
        //     // selection: $state.fileBuffer!.selection
        // )
        // .font(appState.makeTextEditorFont())
        // .lineSpacing(appState.lineSpacing)

        // TextEditor source of truth 동기화 비효율이 심해서
        // TextBufferEditor 를 만들었다. NSTextView.string 을 source 로 쓴다.

        TextBufferEditor()
        //.frame(maxWidth: .infinity, maxHeight: .infinity)
            .focused(focusedViewBinding!, equals: .textEditor)
            .task {
                updateTextViewStyle()
            }

        // TextBufferEditor.updateNSView 에서 스타일까지 업데이트하면 비효율이 심해진다.
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

    func updateTextViewStyle() {
        guard let textView = state.textBuffer?.textView else { return }

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
    //    TextBufferView()
}
