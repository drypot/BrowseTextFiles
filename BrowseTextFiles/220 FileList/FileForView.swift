//
//  FileForView.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import Foundation

nonisolated struct FileForView: Identifiable, Comparable, Hashable {
    // URL 대신 UUID id 를 사용하면 reload 된 Item 의 URL 이 같아도 item 이 변경되었음을 알릴 수 있다.
    let id = UUID()

    var url: URL
    var name: String

    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: FileForView, rhs: FileForView) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: FileForView, rhs: FileForView) -> Bool {
        return lhs.name < rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
