//
//  DirectoryBrowserViewModel.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/10/25.
//

import SwiftUI
import Observation

@Observable
final class DirectoryBrowserViewModel {

    var columns: [URL]
    var pinned:  [Bool]
    var selectedFile: URL?

    init(rootURL: URL) {
        columns = [rootURL]
        pinned  = [true]
    }

    func didTap(_ url: URL, at index: Int) {
        if url.hasDirectoryPath {
            selectDirectory(url, at: index)
        } else {
            selectedFile = url
        }
    }

    func selectDirectory(_ url: URL, at index: Int) {
        guard url.hasDirectoryPath else { return }
        selectedFile = nil
        if pinned[index] {
            columns.insert(url,   at: index + 1)
            pinned.insert(true,  at: index + 1)
        } else {
            columns = Array(columns.prefix(upTo: index)) + [url]
//            pinned  = Array(pinned.prefix(upTo: index))  + [false]
        }
    }

    func goBack(at index: Int) {
        let current = columns[index]
        let parent  = current.deletingLastPathComponent()
        guard parent.path != current.path else { return }
        columns[index] = parent
        selectedFile = nil
    }

    func setPin(_ value: Bool, at index: Int) {
        pinned[index] = value
        if !value {
            let keepCount = index + 1
            columns = Array(columns.prefix(keepCount))
            pinned  = Array(pinned.prefix(keepCount))
            selectedFile = nil
        }
    }
}
