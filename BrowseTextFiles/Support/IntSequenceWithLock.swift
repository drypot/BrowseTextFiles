//
//  IntSequenceWithLock.swift
//  HelloSwift
//
//  Created by Kyuhyun Park on 11/19/24.
//

import Foundation
import os

public struct IntSequenceWithLock: Sequence {
    private let start: Int

    public init(start: Int = 0) {
        self.start = start
    }

    public func makeIterator() -> IntSequenceWithLockIterator {
        return IntSequenceWithLockIterator(current: start)
    }
}

public struct IntSequenceWithLockIterator: IteratorProtocol, Sendable {
    private let lock: OSAllocatedUnfairLock<Int>

    public init(current: Int = 0) {
        self.lock = OSAllocatedUnfairLock<Int>(initialState: current)
    }

    public func next() -> Int? {
        return lock.withLock { state in
            defer {
                state += 1
            }
            return state
        }
    }

}
