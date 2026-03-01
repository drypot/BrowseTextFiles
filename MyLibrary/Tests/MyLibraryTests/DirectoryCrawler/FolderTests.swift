//
//  FolderTests.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 5/15/24.
//

import Foundation
import Testing
import MyLibrary

struct FolderTests {
    func resourceURL(_ path: String = "") -> URL {
        return Bundle.module.resourceURL!
            .appending(path: "DirectoryCrawlerResources")
            .appending(path: path)
    }

    @Test func testBuildFolderTree() throws {
        let root = resourceURL()
        let result = try! FolderTreeBuilder().build(from: root)

        #expect(result.name == "DirectoryCrawlerResources")
        #expect(result.folders!.count == 1)
        #expect(result.folders![0].name == "Sub1")
        #expect(result.folders![0].folders!.count == 2)
        #expect(result.folders![0].folders![0].name == "Sub2")
        #expect(result.folders![0].folders![1].name == "Sub3")
    }
}
