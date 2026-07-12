//
//  SearchState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/1/26.
//

import SwiftUI

nonisolated struct SearchResult: Identifiable {
    struct Line: Identifiable {
        let id = UUID()
        let text: String
    }

    let id = UUID()
    let url: URL
    let title: String
    let lines: [Line]
}

@Observable
final class SearchState {
    var searchText = ""
    var isSearching = false
    var searchResults: [SearchResult]?
    var isSearchWindowPresented = false

    @ObservationIgnored private(set) var browserState: BrowserState

    init(browserState: BrowserState) {
        self.browserState = browserState
    }

    func startSearch(rootURL: URL) {
        consoleLog("search: \"\(searchText)\"")

        if isSearching { return }
        if searchText.isEmpty { return }

        searchResults = []
        isSearching = true

        let pasteboard = NSPasteboard(name: .find)
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(searchText, forType: .string)

        // textView 에 FindBar 를 띄운다.
        // 오바 같아서 comment out;

        // let dummyItem = NSMenuItem()
        // dummyItem.tag = Int(NSFindPanelAction.showFindPanel.rawValue)
        // fileBuffer?.textView?.performTextFinderAction(dummyItem)

        Task {
            do {
                searchResults = try await searchParallel(searchText, at: rootURL)
                consoleLog("search: found \(searchResults?.count ?? 0) files")
            } catch {
                let message = error.localizedDescription
                browserState.leaveAlert(message)
                consoleLog("search: \(message)")
            }
        }

        isSearching = false
    }

    @concurrent
    public func searchParallel(_ searchText: String, at rootURL: URL) async throws -> [SearchResult] {
        let basePath = rootURL.path(percentEncoded: false)
        let basePathLength = basePath.count

        let result = try await withThrowingTaskGroup(of: SearchResult?.self) { group in
            for fileItem in try FileState.collectRecursively(at: rootURL) {
                group.addTask(priority: .userInitiated) {
                    let lines = try Self.filterLines(from: fileItem.url, with: searchText)
                    if fileItem.name.contains(searchText) || lines.count > 0 {
                        let title = String(fileItem.url.path(percentEncoded: false).dropFirst(basePathLength)).precomposedStringWithCanonicalMapping
                        return SearchResult(url: fileItem.url, title: title, lines: lines)
                    } else {
                        return nil
                    }
                }
            }
            var results: [SearchResult] = []
            while let result = try await group.next() {
                guard let result else { continue }
                results.append(result)
            }
            return results.sorted {
                $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
        }

        return result
    }

    nonisolated private static func filterLines(from url: URL, with searchText: String) throws -> [SearchResult.Line] {
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { try? fileHandle.close() }

        var buffer = Data()
        var result: [SearchResult.Line] = []
        //        var count = 0

        while let chunk = try fileHandle.read(upToCount: 4096), !chunk.isEmpty {
            buffer.append(chunk)
            while let range = buffer.range(of: Data([0x0A])) {
                let lineData = buffer.subdata(in: 0..<range.lowerBound)
                buffer.removeSubrange(0...range.lowerBound)
                let text = String(data: lineData, encoding: .utf8)
                if let text, text.contains(searchText) {
                    result.append(SearchResult.Line(text: text))
                    //count += 1
                    //if count >= 5 {
                    //    return result
                    //}
                }
            }
        }

        // 마지막 줄 처리 (개행 없이 끝나는 경우)
        if let text = String(data: buffer, encoding: .utf8),
           text.contains(searchText) {
            result.append(SearchResult.Line(text: text))
        }

        return result
    }

    func clearSearchResult() {
        searchResults = nil
        searchText = ""
    }
}
