//
//  LogStore.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 4/11/26.
//

import Foundation

// use,
// private let log = LogStore.shared.log

struct LogEntry: Identifiable {
    private static let style = Date.ISO8601FormatStyle(timeZone: TimeZone.current)
        .time(includingFractionalSeconds: false)

    let id = UUID()
    let dateTime = Date()
    let message: String

    var description: String {
        let timestamp = dateTime.formatted(Self.style)
        return "\(timestamp), \(message)"
    }
}

@MainActor @Observable
class LogStore {
    static let shared = LogStore()

    private(set) var logs: [LogEntry] = []

    private init() {}

    func log(_ message: String) {
        let entry = LogEntry(message: message)
        logs.append(entry)
        print(entry.description)

        if logs.count > 500 {
            logs.removeFirst()
        }
    }

    func clear() {
        logs.removeAll()
    }
}

