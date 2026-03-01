//
//  URLArrayBuilderTests.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 5/15/24.
//

import Foundation
import Testing
import MyLibrary

struct FileURLCollectorTests {
    func resourceURL(_ path: String = "") -> URL {
        return Bundle.module.resourceURL!
            .appending(path: "DirectoryCrawlerTest")
            .appending(path: path)
    }

    @Test func testCollectShallowly() throws {
        let root = resourceURL()
        let urls = try FileURLCollector().collectShallowly(from: root)
        let sorted = urls.map { url in
            url.path.replacingOccurrences(of: root.path, with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }.sorted()

        #expect(sorted == [
            "dummy1.txt",
            "dummy2.txt"
        ])
    }

    @Test func testCollectRecursively() throws {
        let root = resourceURL()
        let files = try FileURLCollector().collectRecursively(from: root)
        let sorted = files.map { url in
            url.path.replacingOccurrences(of: root.path, with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }.sorted()

        #expect(sorted == [
            "Sub1/Sub2/dummy5.txt",
            "Sub1/Sub2/dummy6.txt",
            "Sub1/Sub3/dummy7.txt",
            "Sub1/Sub3/dummy8.txt",
            "Sub1/dummy3.txt",
            "Sub1/dummy4.txt",
            "dummy1.txt",
            "dummy2.txt"
        ])
    }

    @Test func testCollectRecursivelySub1() throws {
        let root = resourceURL("Sub1")
        let files = try FileURLCollector().collectRecursively(from: root)
        let sorted = files.map { url in
            url.path.replacingOccurrences(of: root.path, with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }.sorted()

        #expect(sorted == [
            "Sub2/dummy5.txt",
            "Sub2/dummy6.txt",
            "Sub3/dummy7.txt",
            "Sub3/dummy8.txt",
            "dummy3.txt",
            "dummy4.txt",
        ])
    }

    @Test func testCollectRecursivelyArray() throws {
        let root = resourceURL()
        let urls = [
            resourceURL("dummy1.txt"),
            resourceURL("Sub1")
        ]

        let files = try FileURLCollector().collectRecursively(from: urls)
        let sorted = files.map { url in
            url.path.replacingOccurrences(of: root.path, with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }.sorted()

        #expect(sorted == [
            "Sub1/Sub2/dummy5.txt",
            "Sub1/Sub2/dummy6.txt",
            "Sub1/Sub3/dummy7.txt",
            "Sub1/Sub3/dummy8.txt",
            "Sub1/dummy3.txt",
            "Sub1/dummy4.txt",
            "dummy1.txt",
        ])
    }
}
