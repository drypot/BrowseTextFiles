//
//  TextEditable.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 8/22/26.
//

import SwiftUI

typealias TextBuffer = Buffer<TextEditable>

@Observable
final class TextEditable: Editable {
    var originalText: String = ""
    var shouldCopyOriginalText = false
    var updateTextViewStyleCount = 0
    var shouldBeFocusedCount = 0

    // Data 에서 NSTextView 링크를 갖는 것이 이상하지만;
    // 효율을 위해 NSTextView.string 을 Source of truth 로 쓴다;
    @ObservationIgnored private weak var textView: NSTextView?
    @ObservationIgnored var isTextViewEdited = false

    init(textView: NSTextView?) {
        self.textView = textView
    }

    func load(contentOf url: URL) throws {
        originalText = try String(contentsOf: url, encoding: .utf8)
        shouldCopyOriginalText = true
    }

    var shouldBeSaved: Bool {
        isTextViewEdited
    }

    func save(to url: URL) throws {
        guard let text = textView?.string else { return }
        guard let data = text.data(using: .utf8) else { return }

        // 이렇게 하면 먼저 붙였던 fileMonitor 가 떨어져 나간다. 하지 말 것.
        // try text.write(to: url, atomically: true, encoding: .utf8)

        let fileHandle = try FileHandle(forWritingTo: url)
        try fileHandle.truncate(atOffset: 0)
        try fileHandle.write(contentsOf: data)
        try fileHandle.close()
        isTextViewEdited = false
    }
}
