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
    @Environment(\.focusedViewBinding) var focusedViewBinding

//    private let debugID = UUID()
    
    var body: some View {
        Group {
            if let loadError = state.fileBuffer?.loadingError {
                VStack(alignment: .leading, spacing: 16) {
                    Text(loadError)
                        .textSelection(.enabled)
                    Button("Reload folder tree") {
                        state.reloadAll()
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else if let _ = state.fileBuffer {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .focused(focusedViewBinding!, equals: .textEditor)
                    .onAppear {
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
            } else {
                Spacer()
            }
        }
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
        .layoutPriority(1)
    }

    func updateTextViewStyle() {
        guard let textView = state.fileBuffer?.textView else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        // lineSpacing 쓰면 엔터 입력시 커서가 사라진다; macOS 26
        // paragraphStyle.lineSpacing = appState.lineSpacing
        paragraphStyle.lineHeightMultiple = appState.lineHeightMultiple

        let attributes: [NSAttributedString.Key: Any] = [
            .font: appState.makeNSFontForText(),
            .paragraphStyle: paragraphStyle
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
