//
//  DirectoryBrowserWindow.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/10/25.
//

import SwiftUI

struct DirectoryBrowserWindow: View {
    @State private var viewModel = DirectoryBrowserViewModel(
        rootURL:
//          FileManager.default.homeDirectoryForCurrentUser
            URL(string: "Documents/SampleFiles", relativeTo: .currentDirectory())!
    )

    var body: some View {
        DirectoryBrowserView()
            .environment(viewModel)
    }

}
