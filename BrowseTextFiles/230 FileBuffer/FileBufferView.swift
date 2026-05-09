//
//  FileBufferView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct FileBufferView: View {
    @Environment(AppState.self) var appState

    var state: FileBrowserState

//    private let debugID = UUID()

    var body: some View {
        Group {
            if let loadError = state.fileBuffer?.loadingError {
                Text(loadError)
                    .font(.custom(appState.fontName, size: appState.fontSize))
                    .lineSpacing(appState.lineSpacing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else if let fileBuffer = state.fileBuffer {
                // let _ = Self._printChanges()

                // TextEditor(
                //     text: fileBuffer.textBinding(),
                //     // selection: $state.fileBuffer!.selection
                // )
                // .font(.custom(appState.fontName, size: appState.fontSize))
                // .lineSpacing(appState.lineSpacing)

                FileBufferEditor(fileBuffer: fileBuffer)

                // 애플 공식문서에 나와있는 것인데 효과 없다.
                // .contentMargins(.horizontal, 20.0, for: .scrollContent)

                // .findDisabled(false)
                // .replaceDisabled(false)

                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    fileBuffer.updateTextViewStyle(appState: appState)
                }
                .onChange(of: appState.fontName) {
                    fileBuffer.updateTextViewStyle(appState: appState)
                }
                .onChange(of: appState.fontSize) {
                    fileBuffer.updateTextViewStyle(appState: appState)
                }
                .onChange(of: appState.lineSpacing) {
                    fileBuffer.updateTextViewStyle(appState: appState)
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
        // .padding(.horizontal, 16)

        // .padding(.top, 16)
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
        .layoutPriority(1)
    }
}

#Preview {
    //    FileBufferView()
}
