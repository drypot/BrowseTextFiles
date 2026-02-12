//
//  Browser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 1/24/26.
//

import SwiftUI
import Observation

@Observable
final class Browser: Identifiable {

    private static var idSeed = 0

    let id = {
        defer { idSeed += 1 }
        return idSeed
    }()

    var title: String
    var rootURL: URL?
    var directoryItems: [URL] = []

    init(rootURL: URL) {
        title = rootURL.lastPathComponent
        self.rootURL = rootURL
    }

    func load() {
        do {
            let raw = try FileManager.default.contentsOfDirectory(
                at: rootURL!,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            directoryItems = raw.sorted { a, b in
                let aIsDir = (try? a.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let bIsDir = (try? b.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if aIsDir == bIsDir {
                    return a.lastPathComponent.lowercased() < b.lastPathComponent.lowercased()
                }
                return aIsDir && !bIsDir
            }
        } catch {
            directoryItems = []
            print("Directory load error:", error)
        }
    }

    var files: [File] = []

}

extension Browser: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Browser: Equatable {
    static func == (lhs: Browser, rhs: Browser) -> Bool {
        return lhs.id == rhs.id
    }
}
