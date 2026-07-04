//
//  LogStore.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 4/11/26.
//

import Foundation

struct LogEntry: Identifiable {
    private static let style = Date.ISO8601FormatStyle(timeZone: TimeZone.current)
        .time(includingFractionalSeconds: false)

    let id: Int
    let description: String
    //let dateTime = Date()

    init(id: Int, message: String) {
        self.id = id

        //let header = dateTime.formatted(Self.style)
        let header = id.formatted(
            .number
                .grouping(.never)
                .precision(.integerLength(4))
        )
        self.description = "\(header): \(message)"
    }
}

@Observable
final class LogStore {
    static let shared = LogStore()

    private(set) var idCount: Int = 0
    private(set) var logs: [LogEntry] = []

    private init() {}

    func log(_ message: String) {
        let entry = LogEntry(id: idCount, message: message)
        idCount += 1
        print(entry.description)
        logs.append(entry)
        if logs.count > 300 {
            logs.removeFirst()
        }
    }

    func clear() {
        logs.removeAll()
    }
}

func consoleLog(_ message: String) {
    LogStore.shared.log(message)
}

func printLog(_ message: String) {
    print("----: \(message)")
}
