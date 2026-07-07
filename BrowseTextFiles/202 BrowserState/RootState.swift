//
//  RootState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/7/26.
//

import SwiftUI

@Observable
final class RootState {
    private(set) var rootURL: URL?
    private(set) var rootName: String?
    private(set) var rootPath: String?
    private(set) var rootPathComponents: [String]?
    private var shouldReleaseSecurityScopedResource = false

    var isReady: Bool {
        rootURL != nil
    }

    func configure(with rootURL: URL) {
        self.rootURL = rootURL
        self.rootName = rootURL.lastPathComponent
        self.rootPath = rootURL.path(percentEncoded: false)
        self.rootPathComponents = rootURL.pathComponents
        self.shouldReleaseSecurityScopedResource = rootURL.startAccessingSecurityScopedResource()
    }

    func releaseResource() {
        guard let rootURL else { return }
        if shouldReleaseSecurityScopedResource {
            rootURL.stopAccessingSecurityScopedResource()
            shouldReleaseSecurityScopedResource = false
        }
    }
}
