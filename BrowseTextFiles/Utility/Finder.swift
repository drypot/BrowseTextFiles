//
//  Finder.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/13/26.
//

import Foundation
import AppKit

struct Finder {
    public static let shared = Finder()

    private init() {}

    func open(url: URL) {
        let path = url.path
        if FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
        } else {
            let folderURL = url.deletingLastPathComponent()
            NSWorkspace.shared.open(folderURL)
        }
    }
}
