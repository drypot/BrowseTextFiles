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
        let styler = Styler.shared
        Group {
            if let loadError = state.fileBuffer?.loadingError {
                Text(loadError)
                    .font(appState.makeFontForText())
                    .lineSpacing(appState.lineSpacing)
                    .textSelection(.enabled)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else if let fileBuffer = state.fileBuffer {
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
                    .focused(focusedViewBinding!, equals: .textEditor)
                    .onAppear {
                        styler.updateTextViewStyle(fileBuffer.textView, appState)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // TextBufferEditor.updateNSView 에서 스타일까지 업데이트하면 비효율이 심해진다.
                // 여기로 따로 빼놨다.
                .onChange(of: appState.fontName) {
                    styler.updateTextViewStyle(fileBuffer.textView, appState)
                }
                .onChange(of: appState.fontSize) {
                    styler.updateTextViewStyle(fileBuffer.textView, appState)
                }
                .onChange(of: appState.lineSpacing) {
                    styler.updateTextViewStyle(fileBuffer.textView, appState)
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
}

#Preview {
    //    TextBufferView()
}
