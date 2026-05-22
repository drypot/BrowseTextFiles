//
//  URLTests.swift
//  Browse Text Files Tests
//
//  Created by Kyuhyun Park on 5/22/26.
//

import Foundation
import Testing

struct URLTests {

    @Test func testAppending() throws {
        do {
            let parent = URL(fileURLWithPath: "/Users/drypot/Documents")
            let child = parent.appending(path: "File1.txt")
            #expect(child.path == "/Users/drypot/Documents/File1.txt")
        }
        do {
            let parent = URL(fileURLWithPath: "/Users/drypot/Documents/")
            let child = parent.appending(path: "File1.txt")
            #expect(child.path == "/Users/drypot/Documents/File1.txt")
        }
    }

}
