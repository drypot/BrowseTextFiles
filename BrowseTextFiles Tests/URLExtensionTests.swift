//
//  URLExtensionTests.swift
//  Browse Text Files Tests
//
//  Created by Kyuhyun Park on 5/22/26.
//

import Foundation
import Testing

struct URLExtensionTests {

    @Test func testIsChild() throws {
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/alex/Documents/Test/file.txt")
            #expect(child.isChild(of: parent) == false)
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents")
            #expect(child.isChild(of: parent) == false)
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents/")
            #expect(child.isChild(of: parent) == false)
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents/file.txt")
            #expect(child.isChild(of: parent) == true)
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents/Test/file.txt")
            #expect(child.isChild(of: parent) == true)
        }
    }

    @Test func testIsChildOrEqual() throws {
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/alex/Documents/Test/file.txt")
            #expect(child.isChildOrEqual(to: parent) == false)
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents")
            #expect(child.isChildOrEqual(to: parent) == true)
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents/")
            #expect(child.isChildOrEqual(to: parent) == true)
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents/file.txt")
            #expect(child.isChildOrEqual(to: parent) == true)
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents/Test/file.txt")
            #expect(child.isChildOrEqual(to: parent) == true)
        }
    }

    @Test func testRelativePath() throws {
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/alex/Documents/Test/file.txt")
            #expect(child.relativePath(from: parent) == nil)
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents")
            #expect(child.relativePath(from: parent) == ".")
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents/")
            #expect(child.relativePath(from: parent) == ".")
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents/file.txt")
            #expect(child.relativePath(from: parent) == "file.txt")
        }
        do {
            let parent = URL(filePath: "/Users/drypot/Documents")
            let child = URL(filePath: "/Users/drypot/Documents/Test/file.txt")
            #expect(child.relativePath(from: parent) == "Test/file.txt")
        }
    }
}
