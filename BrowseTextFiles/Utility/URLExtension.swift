//
//  URLExtension.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 5/22/26.
//

import Foundation

extension URL {
    func isChild(of parent: URL) -> Bool {
        let childComponents = self.standardized.pathComponents
        let parentComponents = parent.standardized.pathComponents
        guard childComponents.count > parentComponents.count else { return false }
        return childComponents.starts(with: parentComponents)
    }

    func isChildOrEqual(to parent: URL) -> Bool {
        let childComponents = self.standardized.pathComponents
        let parentComponents = parent.standardized.pathComponents
        return childComponents.starts(with: parentComponents)
    }

    func relativePath(from parent: URL) -> String? {
        let childComponents = self.standardized.pathComponents
        let parentComponents = parent.standardized.pathComponents
        guard childComponents.starts(with: parentComponents) else { return nil }
        let relativeComponents = childComponents.dropFirst(parentComponents.count)
        return relativeComponents.joined(separator: "/")
    }
}
