//
//  BrowserTask.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserTask: ViewModifier {
    @Environment(AppState.self) var appState
    @Environment(RootState.self) var rootState
    @Environment(BrowserState.self) var browserState
    @Environment(FolderListState.self) var folderListState

    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    func body(content: Content) -> some View {
        content
            .task {
                // SceneStorage 가 업데이트 될 때까지 한 사이클 쉰다.
                await Task.yield()
                initialize()
            }
            .onChange(of: rootState.browserState.rootURL) {
                rootURLChanged()
            }
            .onChange(of: rootState.browserState.selectedFileURL) {
                fileURLChanged()
            }
    }

    func initialize() {
        var sceneRootURL: URL? = nil
        var sceneFileURL: URL? = nil
        var isStale = false

        if let data = sceneRootURLData {
            sceneRootURL = try? URL(resolvingBookmarkData: data,
                                    options: .withSecurityScope,
                                    relativeTo: nil,
                                    bookmarkDataIsStale: &isStale)
        }
        consoleLog("restore root url: \(sceneRootURL?.path(percentEncoded: false) ?? "nil")")

        if let data = sceneFileURLData {
            sceneFileURL = try? URL(resolvingBookmarkData: data,
                                    options: .withSecurityScope,
                                    relativeTo: nil,
                                    bookmarkDataIsStale: &isStale)
        }
        consoleLog("restore file url: \(sceneFileURL?.path(percentEncoded: false) ?? "nil")")

        if let rootURL = sceneRootURL {
            rootState.configure(with: rootURL, appState: appState)
            if let fileURL = sceneFileURL {
                rootState.targetFile(fileURL)
            }
            return
        }

        if let rootURL = appState.newWindowRootURL {
            rootState.configure(with: rootURL, appState: appState)
            if let fileURL = appState.newWindowFileURL {
                rootState.targetFile(fileURL)
            }
            appState.newWindowRootURL = nil
            appState.newWindowFileURL = nil
            return
        }

        browserState.status = .showOpenPanel
    }

    func rootURLChanged() {
        guard let rootURL = rootState.browserState.rootURL else { return }
        consoleLog("save root url: \(rootURL.path(percentEncoded: false))")
        sceneRootURLData = try? rootURL.bookmarkData(options: .withSecurityScope)
        appState.addRecentDocumentURL(rootURL)
    }

    func fileURLChanged() {
        guard let fileURL = rootState.browserState.selectedFileURL else { return }
        //consoleLog("save file url: \(fileURL.path(percentEncoded: false))")
        sceneFileURLData = try? fileURL.bookmarkData(options: .withSecurityScope)
    }

}


