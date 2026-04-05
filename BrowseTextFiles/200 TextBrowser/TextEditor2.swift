//
//  TextEditor2.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/5/26.
//

import SwiftUI

struct TextEditor2: View {
    @Environment(SettingsData.self) var settings

    @Bindable var buffer: TextBuffer

    var body: some View {
        TextEditor(text: $buffer.text)
            .font(.custom(settings.fontName, size: settings.fontSize))
            .lineSpacing(settings.lineSpacing)
            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
    }
}

#Preview {
//    TextEditor2()
}
