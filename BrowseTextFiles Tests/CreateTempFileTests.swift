//
//  CreateTempFileTests.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 4/6/26.
//

import Foundation
import Testing

struct CreateTempFileTests {

    let tempFileContent = "..."

    func getOrCreateTempFile() throws -> URL {
        let fileManager = FileManager.default

        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("testSecurityScoped.txt")

        if !fileManager.fileExists(atPath: fileURL.path) {
            try tempFileContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("new temp file created")
        } else {
            print("reuse temp file")
        }

        return fileURL
    }

    @Test func testTempFile() throws {
        // ...
    }

}
