//
//  BrowserTask.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserTask: ViewModifier {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @SceneStorage("rootURLData") private var sceneRootURLData: Data?
    @SceneStorage("fileURLData") private var sceneFileURLData: Data?

    func body(content: Content) -> some View {
        content
            .task {
                // SceneStorage 가 업데이트 될 때까지 한 사이클 쉰다.
                await Task.yield()
                initialize()
            }
            .onChange(of: browser.context.rootURL) {
                rootURLChanged()
            }
            .onChange(of: browser.context.selectedFileURL) {
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
            browser.configure(with: rootURL, app: app)
            if let fileURL = sceneFileURL {
                browser.targetFile(fileURL)
            }
            return
        }

        if let rootURL = app.newWindowRootURL {
            browser.configure(with: rootURL, app: app)
            if let fileURL = app.newWindowFileURL {
                browser.targetFile(fileURL)
            }
            app.newWindowRootURL = nil
            app.newWindowFileURL = nil
            return
        }

        browser.context.status = .showOpenPanel
    }

    func rootURLChanged() {
        guard let rootURL = browser.context.rootURL else { return }
        consoleLog("save root url: \(rootURL.path(percentEncoded: false))")
        sceneRootURLData = try? rootURL.bookmarkData(options: .withSecurityScope)
        app.addRecentDocumentURL(rootURL)
    }

    func fileURLChanged() {
        guard let fileURL = browser.context.selectedFileURL else { return }
        //consoleLog("save file url: \(fileURL.path(percentEncoded: false))")
        sceneFileURLData = try? fileURL.bookmarkData(options: .withSecurityScope)
    }

}


