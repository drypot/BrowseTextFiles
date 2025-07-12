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

    var directoryURLs: [URL]
    var selectedFileURL: URL?

    init(rootURL: URL) {
        directoryURLs = [rootURL]
    }

    func didTap(_ url: URL, at index: Int) {
        directoryURLs = Array(directoryURLs.prefix(through: index))
        if url.hasDirectoryPath {
            directoryURLs += [url]
        } else {
            selectedFileURL = url
        }
        dumpURLs()
    }

    func dumpURLs() {
        print("***")
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
