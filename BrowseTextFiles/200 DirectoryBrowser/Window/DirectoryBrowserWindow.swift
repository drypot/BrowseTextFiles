//
//  DirectoryBrowserWindow.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/10/25.
//

import SwiftUI

struct DirectoryBrowserWindow: View {

    static var urlsToOpen: [URL] = []

    @State private var browser: DirectoryBrowser

    init() {
        let rootURL = Self.urlsToOpen.popLast() ?? URL(string: "Documents", relativeTo: .currentDirectory())!
        let viewModel = DirectoryBrowser(rootURL: rootURL)
        _browser = State(wrappedValue: viewModel)
    }

    var body: some View {
        DirectoryBrowserView()
            .environment(browser)
    }

}
