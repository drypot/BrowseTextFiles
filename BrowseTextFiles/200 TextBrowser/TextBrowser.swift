//
//  TextBrowser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

struct TextBrowser: View {
    @Environment(SettingsData.self) var settings
    @SceneStorage("rootURLData") private var rootURLData: Data?

    @State private var bufferManager = TextBufferManager()

    private var initURL: URL?

    init(_ url: URL? = nil) {
        initURL = url
    }

    var body: some View {
        VStack {
            if bufferManager.isReady {
                TextBrowserReady(bufferManager: bufferManager)
            } else {
                Button("Open Folder") {
                    openFolderFromBlank()
                }
            }
        }
        .focusedSceneValue(\.selectedBufferManager, bufferManager)
        .toolbarBackground(.background, for: .windowToolbar)
        .toolbarBackgroundVisibility(.automatic, for: .windowToolbar)
        .toolbar(removing: .title)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                ControlGroup {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                    }
                    .help("이전 항목으로 이동")

                    Button(action: {}) {
                        Image(systemName: "chevron.right")
                    }
                    .help("다음 항목으로 이동")
                }
                .controlGroupStyle(.navigation) // macOS 스타일의 화살표 묶음으로 표시된다
            }
        }
        .task {
            if let initURL {
                openFolderFromInitURL(initURL)
            } else {
                openFolderFromRestoredURL()
            }
        }
    }

    func openFolderFromInitURL(_ url: URL) {
        print("openFolderFromInitURL: \(url.absoluteString)")
        bufferManager.openURL(url)
        if let url = bufferManager.rootURL {
            saveBookmark(url)
            settings.addRecentDocumentURL(url)
        }
    }

    func openFolderFromRestoredURL() {
        print("openFolderFromRestoredURL: ...")
        if let url = loadBookmark() {
            print("openFolderFromRestoredURL: \(url.absoluteString)")
            bufferManager.openURL(url)
        }
    }

    func openFolderFromBlank() {
        print("openFolderFromBlank: ...")
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        if panel.runModal() == .OK, let url = panel.url {
            print("openFolderFromBlank: \(url.absoluteString)")
            openFolderFromInitURL(url)
        }
    }

    func saveBookmark(_ url: URL) {
        do {
            try withSecurityScope(url) {
                rootURLData = try url.bookmarkData(options: .withSecurityScope)
            }
        } catch {
            print("saving bookmark failed: \(error)")
        }
    }

    func loadBookmark() -> URL? {
        do {
            guard let data = rootURLData else { return nil }
            var isStale = false
            let url = try URL(resolvingBookmarkData: data,
                              options: .withSecurityScope,
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            if isStale {
                saveBookmark(url)
            }
            return url
        } catch {
            print("loading bookmark failed: \(error)")
        }
        return nil
    }
}

#Preview {
    let settings = SettingsData()
    TextBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
