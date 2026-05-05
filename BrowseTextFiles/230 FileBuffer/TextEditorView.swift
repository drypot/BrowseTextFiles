//
//  TextEditorView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import SwiftUI

struct TextEditorView: View {
    @Environment(SettingsData.self) var settings

    @Bindable var status: FileBrowserStatus
    @FocusState var isFocused: Bool

    var body: some View {
        Group {
            if status.isShowSearchView {
                SearchResultView(status: status)
            } else if let loadError = status.fileBuffer?.loadError {
                Text(loadError)
                    .font(.custom(settings.fontName, size: settings.fontSize))
                    .lineSpacing(settings.lineSpacing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else if let buffer = status.fileBuffer {
                @Bindable var buffer = buffer
                TextEditor(text: buffer.textBinding(), selection: $buffer.selection)
                // 애플 공식문서에 나와있는 것인데 효과 없다.
                // .contentMargins(.horizontal, 20.0, for: .scrollContent)
                    .focused($isFocused)
                    .findDisabled(false)
                    .replaceDisabled(false)
                    .font(.custom(settings.fontName, size: settings.fontSize))
                    .lineSpacing(settings.lineSpacing)
                    .onAppear {
                        isFocused = true
                    }
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
}

#Preview {
    //    TextEditorView()
}
