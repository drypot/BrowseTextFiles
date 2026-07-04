//
//  IntGenerator.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/4/26.
//

import Foundation

struct IntGenerator {
    private var nextValue: Int

    public init(_ nextValue: Int = 0) {
        self.nextValue = nextValue
    }

    public mutating func next() -> Int {
        defer { nextValue += 1 }
        return nextValue
    }
}
