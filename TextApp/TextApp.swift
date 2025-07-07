//
//  TextApp.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI

@main
struct TextApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
//            DirectoryBrowserView(rootDirectory: rootURL())
//            FileTextView(fileURL: sampleTextURL())
            DirectoryBrowserView(initialURL: rootURL())
        }
    }

    func rootURL() -> URL {
//        return FileManager.default.homeDirectoryForCurrentUser
        return URL(string: "Documents/SampleTextFiles", relativeTo: .currentDirectory())!
    }

    func sampleTextURL() -> URL {
        return URL(string: "Documents/SampleTextFiles/Readme.txt", relativeTo: .currentDirectory())!
    }
}
