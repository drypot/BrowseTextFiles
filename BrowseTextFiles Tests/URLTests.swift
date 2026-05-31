//
//  URLTests.swift
//  Browse Text Files Tests
//
//  Created by Kyuhyun Park on 5/22/26.
//

import Foundation
import Testing

struct URLTests {

    @Test func testInitString() {
        do {
            let url = URL(string: "/Users/drypot/File 1.txt")
            #expect(url?.path == "/Users/drypot/File 1.txt")
        }
    }

    @Test func testInitFilePath() {
        do {
            let url = URL(filePath: "/Users/drypot")
            #expect(url.path == "/Users/drypot")
        }
        do {
            let url = URL(filePath: "/Users/drypot", directoryHint: .isDirectory)
            #expect(url.path == "/Users/drypot")
        }
        do {
            let url = URL(filePath: "/Users/drypot/", directoryHint: .isDirectory)
            #expect(url.path == "/Users/drypot")
        }
        do {
            let url = URL(filePath: "/Users/drypot", directoryHint: .isDirectory)
            let url2 = URL(filePath: "File 1.txt", directoryHint: .notDirectory, relativeTo: url)
            #expect(url2.path == "/Users/drypot/File 1.txt")
        }
    }

    @Test func testPath() throws {
        do {
            let url = URL(filePath: "/Users/drypot/File 1.txt")
            #expect(url.path == "/Users/drypot/File 1.txt") // deprecated
            #expect(url.path(percentEncoded: true) == "/Users/drypot/File%201.txt")
            #expect(url.path(percentEncoded: false) == "/Users/drypot/File 1.txt")

            #expect(url.absoluteString == "file:///Users/drypot/File%201.txt")
            #expect(url.absoluteURL.path == "/Users/drypot/File 1.txt")

            #expect(url.relativePath == "/Users/drypot/File 1.txt")
            #expect(url.relativeString == "file:///Users/drypot/File%201.txt")
        }
    }

    @Test func testPathComponents() throws {
        do {
            let url = URL(filePath: "/Users/drypot/File 1.txt")
            #expect(url.pathComponents == ["/", "Users", "drypot", "File 1.txt"])
            #expect(url.pathComponents.joined(separator: "/") == "//Users/drypot/File 1.txt")
            #expect(["Users", "drypot", "File 1.txt"].joined(separator: "/") == "Users/drypot/File 1.txt")
        }
    }

    @Test func testAppending() throws {
        do {
            let url = URL(filePath: "/Users/drypot")
            #expect(url.appending(path: "File 1.txt").path == "/Users/drypot/File 1.txt")
        }
        do {
            let url = URL(filePath: "/Users/drypot/")
            #expect(url.appending(path: "File 1.txt").path == "/Users/drypot/File 1.txt")
        }
        do {
            let url = URL(filePath: "/Users/drypot/Documents")
            #expect(url.appending(path: "File 1.txt").path == "/Users/drypot/Documents/File 1.txt")
            #expect(url.appending(path: "../File 1.txt").path == "/Users/drypot/Documents/../File 1.txt")
            #expect(url.appending(path: "../File 1.txt").standardizedFileURL.path == "/Users/drypot/File 1.txt")
        }
    }

}
