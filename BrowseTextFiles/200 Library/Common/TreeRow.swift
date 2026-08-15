//
//  TreeRow.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 6/29/26.
//

import SwiftUI

struct TreeRow<Node, RowContent>: View where Node: Identifiable, RowContent: View {
    let node: Node
    let children: KeyPath<Node, [Node]?>
    var expanded: Binding<Set<Node.ID>>
    let rowContent: (Node) -> RowContent

    init(_ node: Node,
         children: KeyPath<Node, [Node]?>,
         expanded: Binding<Set<Node.ID>>,
         @ViewBuilder rowContent: @escaping (Node) -> RowContent) {

        self.node = node
        self.children = children
        self.expanded = expanded
        self.rowContent = rowContent
    }

    var body: some View {
        if let childNodes = node[keyPath: children] {
            let isExpanded = Binding(
                get: { expanded.wrappedValue.contains(node.id) },
                set: {
                    if $0 {
                        expanded.wrappedValue.insert(node.id)
                    } else {
                        expanded.wrappedValue.remove(node.id)
                    }
                }
            )
            DisclosureGroup(isExpanded: isExpanded) {
                ForEach(childNodes) { child in
                    TreeRow(child, children: children, expanded: expanded, rowContent: rowContent)
                }
            } label: {
                rowContent(node)
            }
        } else {
            rowContent(node)
        }
    }
}
