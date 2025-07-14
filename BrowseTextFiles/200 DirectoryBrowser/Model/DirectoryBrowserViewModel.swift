//
//  DirectoryBrowserViewModel.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/10/25.
//

import SwiftUI
import Observation

@Observable
final class DirectoryBrowserViewModel {

    var title: String
    var directoryURLs: [URL]
    var selectedFileURL: URL?

    init(rootURL: URL) {
        title = rootURL.lastPathComponent
        directoryURLs = [rootURL]
    }

    func didTap(_ url: URL, at index: Int) {
        if url.hasDirectoryPath {
            directoryURLs = Array(directoryURLs.prefix(through: index)) + [url]
        } else {
            selectedFileURL = url
        }
//        dumpURLs()
    }

    func dumpURLs() {
        print("ViewModel, directoryURLs:")
        for url in directoryURLs {
            let path = url.absoluteString
            if let range = path.range(of: "/Documents") {
                let start = path.index(range.upperBound, offsetBy: 1)
                let relative = String(path[start...])
                print(relative)
            }
        }
    }

}
