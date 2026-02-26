//
//  BookmarkManager.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 2/26/26.
//

import Foundation

class BookmarkManager {
    static var shared = BookmarkManager()
    private init() {}
    
    func save(_ url: URL, forKey key: String) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                                                    includingResourceValuesForKeys: nil,
                                                    relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: key)
        } catch {
            print("saveBookmark failed: \(error)")
        }
    }

    func load(forKey key: String) -> URL? {
        var url: URL? = nil
        do {
            guard let bookmarkData = UserDefaults.standard.data(forKey: key) else { return nil }

            var isStale = false
            url = try URL(resolvingBookmarkData: bookmarkData,
                              options: .withSecurityScope,
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)
            if isStale {
                save(url!, forKey: key)
            }
        } catch {
            print("loadBookmark failed: \(error)")
        }
        return url
    }
}
