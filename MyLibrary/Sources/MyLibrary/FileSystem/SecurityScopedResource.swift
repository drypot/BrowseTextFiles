//
//  SecurityScopedResource.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 4/6/26.
//

import Foundation

// deinit 에 의존하는 이 방식은 쓰면 안 될 듯.
// 바로 Object 가 deinit 된다;
// let _ = SecurityScope(for: url)

// 이 방식은 잘 동작한다.
// let securityScope = SecurityScope(for: url)
// defer { securityScope.stopAccessing() }

public class SecurityScope {
    let url: URL
    private(set) var isAccessing: Bool = false

    public init(for url: URL) {
        self.url = url
        self.isAccessing = url.startAccessingSecurityScopedResource()
//        print("SecurityScope: isAccessing == \(isAccessing)")
    }
    
//    deinit {
//        stopAccessing()
//    }
    
    public func stopAccessing() {
        if isAccessing {
            url.stopAccessingSecurityScopedResource()
            isAccessing = false
//            print("SecurityScope: stopped")
        }
    }
}

public func withSecurityScope<T>(_ url: URL, block: () throws -> T) throws -> T {
    let isAccessing = url.startAccessingSecurityScopedResource()

    defer {
        if isAccessing { url.stopAccessingSecurityScopedResource() }
//        print("SecurityScope: stopped")
    }

//    print("SecurityScope: isAccessing == \(isAccessing)")
    return try block()
}
