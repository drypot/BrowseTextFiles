//
//  FolderInTextBrowser.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 3/1/26.
//

import SwiftUI
import MyLibrary

@Observable
final class FolderInTextBrowser {
    private(set) var url: URL?
    private(set) var fileURLs: [URL]?
    public var selectedFileURL: URL?

    var isReady: Bool {
        url != nil
    }

    func reset() {
        url = nil
        fileURLs = nil
        selectedFileURL = nil
    }

    func loadFolder(from url: URL) throws {
        reset()
        fileURLs = try TextFileURLCollector().collectShallowly(from: url)
        fileURLs?.sort { $0.lastPathComponent < $1.lastPathComponent }
        self.url = url
    }

    func contains(_ url: URL) -> Bool {
        fileURLs?.contains(url) ?? false
    }
}
