//
//  File.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 2/3/26.
//

import Foundation

@Observable
class File {
    var url: URL
    var content: String

    init(url: URL, content: String) {
        self.url = url
        self.content = content
    }
}
