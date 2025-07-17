//
//  DirectoryBrowserWindow.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/10/25.
//

import SwiftUI

struct DirectoryBrowserWindow: View {

    static var urlsToOpen: [URL] = []

    @State private var viewModel: DirectoryBrowserViewModel

    init() {
        let rootURL = Self.urlsToOpen.popLast() ?? URL(string: "Documents", relativeTo: .currentDirectory())!
        let viewModel = DirectoryBrowserViewModel(rootURL: rootURL)
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        DirectoryBrowserView()
            .environment(viewModel)
    }

}
