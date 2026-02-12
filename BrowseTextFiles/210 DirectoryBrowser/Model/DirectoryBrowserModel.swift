//
//  DirectoryBrowserModel.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/10/25.
//

import SwiftUI
import Observation

@Observable
final class DirectoryBrowserModel {

    struct Column: Identifiable, Equatable, Hashable {
        private static var idSeed = 0

        let id = {
            defer { idSeed += 1 }
            return idSeed
        }()

        let index: Int
        let directoryURL: URL

        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    var title: String
    var columns: [Column]
    var selectedFileURL: URL?

    init(rootURL: URL) {
        title = rootURL.lastPathComponent
        columns = [Column(index:0, directoryURL: rootURL)]
    }

    func didTap(_ url: URL, at index: Int) {
        guard index < columns.count else { return }
        if url.hasDirectoryPath {
            columns = Array(columns.prefix(index + 1)) + [Column(index: index + 1, directoryURL: url)]
        } else {
            selectedFileURL = url
        }
//        dumpURLs()
    }

    func dumpURLs() {
        print("ViewModel, directoryURLs:")
        for column in columns {
            let path = column.directoryURL.absoluteString
            if let range = path.range(of: "/Documents") {
                let start = path.index(range.upperBound, offsetBy: 1)
                let relative = String(path[start...])
                print(relative)
            }
        }
    }

}
