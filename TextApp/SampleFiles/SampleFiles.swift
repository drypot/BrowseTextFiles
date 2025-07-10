//
//  SampleFiles.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/10/25.
//

import Foundation

// 좀 만들다가 오바 같아서 중지;
// 그냥 수작업으로 SampleFiles 폴더 만드는 게 낫겠다;

class SampleFiles {

    var rootURL: URL?

    func createFiles() throws {
        let fileManager = FileManager.default
        rootURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        let paths = [
            "",

            "Sub1",
            "Sub2",
            "Sub3",

            "Sub1/Sub1/Sub1",
            "Sub1/Sub1/Sub2",
            "Sub1/Sub1/Sub3",

            "Sub1/Sub2/Sub1",
            "Sub1/Sub2/Sub2",
            "Sub1/Sub2/Sub3",

            "Sub1/Sub3",

            "Sub2/Sub1",
            "Sub2/Sub2",
            "Sub2/Sub3",

            "Sub3/Sub1",
            "Sub1/Sub2/Sub3",
            "Sub1/Sub2/Sub3",
            "Sub1/Sub2/Sub3",
        ]

        for path in paths {
            let dirURL = rootURL!.appendingPathComponent(path)
            try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true)

            for i in 1...2 {
                let fileURL = dirURL.appendingPathComponent("file\(i).txt")
                let content = "This is file\(i) in \(path)"
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        }
    }

    func removeFiles() throws {
        try FileManager.default.removeItem(at: rootURL!)
    }
}

