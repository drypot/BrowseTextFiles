//
//  TextKitUtil.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/19/26.
//

import SwiftUI

struct TextKitUtil {
    static func makeFileNameSelection(from fileName: String) -> TextSelection {
        if let dotIndex = fileName.lastIndex(of: ".") {
            let range = fileName.startIndex..<dotIndex
            return TextSelection(range: range)
        } else {
            return TextSelection(range: fileName.startIndex..<fileName.endIndex)
        }
    }
}
