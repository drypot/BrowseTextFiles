//
//  Log.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 4/11/26.
//

import Foundation

// use,
// private let log = LogStore.shared.log

public struct LogEntry: Identifiable {
    private static let style = Date.ISO8601FormatStyle(timeZone: TimeZone.current)
        .time(includingFractionalSeconds: false)

    public let id = UUID()
    public let dateTime = Date()
    public let message: String

    public var description: String {
        let timestamp = dateTime.formatted(Self.style)
        return "\(timestamp), \(message)"
    }
}

@MainActor @Observable
public class LogStore {
    public static let shared = LogStore()

    private(set) var logs: [LogEntry] = []

    private init() {}

    public func log(_ message: String) {
        let entry = LogEntry(message: message)
        logs.append(entry)
        print(entry.description)

        if logs.count > 500 {
            logs.removeFirst()
        }
    }

    public func clear() {
        logs.removeAll()
    }
}

