//
//  IntSequence.swift
//  HelloSwift
//
//  Created by Kyuhyun Park on 7/15/25.
//

import Foundation

public struct IntSequence: Sequence {
    private let start: Int

    public init(start: Int = 0) {
        self.start = start
    }

    public func makeIterator() -> IntSequenceIterator {
        return IntSequenceIterator(current: start)
    }
}

public struct IntSequenceIterator: IteratorProtocol {
    private var current: Int

    public init(current: Int) {
        self.current = current
    }

    public mutating func next() -> Int? {
        defer { current += 1 }
        return current
    }
}
