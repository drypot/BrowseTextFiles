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
    var selectedFile: URL?

    init(rootURL: URL) {
        columns = [rootURL]
    }

    func didTap(_ url: URL, at index: Int) {
        columns = Array(columns.prefix(through: index))
        if url.hasDirectoryPath {
            columns += [url]
        } else {
            selectedFile = url
        }
    }

    func goBack(at index: Int) {
        let current = columns[index]
        let parent  = current.deletingLastPathComponent()
        guard parent.path != current.path else { return }
        columns[index] = parent
        selectedFile = nil
    }

    func setPin(at index: Int) {
        columns = Array(columns.prefix(upTo: index))
    }
    
}
