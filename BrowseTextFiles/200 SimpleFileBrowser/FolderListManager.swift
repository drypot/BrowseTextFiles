//
//  FolderListManager.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 2/26/26.
//

import Foundation

class Folder: Identifiable, Hashable {
    let url: URL
    let name: String
    var folders: [Folder]?

    var id: URL { url }

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Observable
class FolderListManager {
    var root: Folder?
    var folders: [Folder] = []

    func setRoot(to url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        if let folder = try? FolderTreeBuilder().build(from: url) {
            root = folder
            // SwiftUI List 에 root folder 를 표시하기 위해 root 용 어레이를 만들어 둔다.
            folders = [folder]
        }
    }
}

struct FolderTreeBuilder {
    func build(from rootURL: URL) throws -> Folder {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        func buildFolderNode(from url: URL) throws -> Folder {
            let fileManager = FileManager.default
            let folder = Folder(url: url)

            var urls = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: keys,
                options: options
            )
            urls.sort { $0.lastPathComponent < $1.lastPathComponent }

            for url in urls {
                try autoreleasepool {
                    let values = try url.resourceValues(forKeys: keySet)
                    if values.isDirectory == true {
                        let childFolder = try buildFolderNode(from: url)
                        if folder.folders == nil {
                            folder.folders = [childFolder]
                        } else {
                            folder.folders!.append(childFolder)
                        }
                    }
                }
            }

            return folder
        }

        return try buildFolderNode(from: rootURL)
    }
}
