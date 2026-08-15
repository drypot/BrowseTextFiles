//
//  URLExtension.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 5/22/26.
//

import Foundation

extension URL {
    func isParent(of child: URL) -> Bool {
        let parentComponents = self.pathComponents
        let childComponents = child.pathComponents
        guard parentComponents.count < childComponents.count else { return false }
        return childComponents.starts(with: parentComponents)
    }

    func isParentOrEqual(to child: URL) -> Bool {
        let parentComponents = self.pathComponents
        let childComponents = child.pathComponents
        return childComponents.starts(with: parentComponents)
    }

    func isChild(of parent: URL) -> Bool {
        parent.isParent(of: self)
    }

    func isChildOrEqual(to parent: URL) -> Bool {
        parent.isParentOrEqual(to: self)
    }

    func relativePath(from parent: URL) -> String? {
        let childComponents = self.standardized.pathComponents
        let parentComponents = parent.standardized.pathComponents
        guard childComponents.starts(with: parentComponents) else { return nil }
        if childComponents.count == parentComponents.count {
            return "."
        } else {
            return childComponents.dropFirst(parentComponents.count).joined(separator: "/")
        }
    }
}
