//
//  TestSecurityScopedBookmark.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/6/26.
//

import Foundation
import AppKit
import MyLibrary

struct TestSecurityScopedBookmark {
    func testASS() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        if panel.runModal() == .OK, let url = panel.url {
            do {
                do {
                    // 다이얼로그에서 파일 하나 찍어서 오픈하면, 성공,
                    // startAccessingSecurityScopedResource 하지 않아도 읽힌다.
                    // print("data: try 1")
                    // _ = try Data(contentsOf: url)
                }

                do {
                    // 다이얼로그에서 파일 하나 찍고, 그 옆에 파일을 오픈하려고 하면, 실패,
                    // print("data: try 2")
                    // let url = url.deletingLastPathComponent().appendingPathComponent("file02.txt")
                    // _ = try Data(contentsOf: url)
                }

                do {
                    // 다이얼로그에서 파일 하나 찍고, 그 옆에 파일을 오픈하려고 하면,
                    // startAccessingSecurityScopedResource 에 상관없이 실패,
                    // print("data: try 3")
                    // let url = url.deletingLastPathComponent().appendingPathComponent("file02.txt")
                    // let accessing = url.startAccessingSecurityScopedResource()
                    // defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                    // _ = try Data(contentsOf: url)
                }

                do {
                    // 다이얼로그에서 폴더를 찍고, 그 안에 파일을 읽으려고 하면, 성공,
                    // print("data: try 4")
                    // let url = url.appendingPathComponent("file02.txt")
                    //let accessing = url.startAccessingSecurityScopedResource()
                    //defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                    // _ = try Data(contentsOf: url)
                }

                do {
                    // 날쌩 URL 을 새로 만들어서 접근하려고 하면?, 다이얼로그에서 일단 찍었으니, 성공,
                    // print("data: try 5")
                    // let url = URL(string: url.absoluteString)!
                    //  _ = try Data(contentsOf: url)
                }

                do {
                    // 다이얼로그에서 파일 하나 찍어서 북마크 만들고,
                    print("data: try 6")

                    // NSOpenPanel 에서 받은 url 에서 bookmarkData 생성할 때는 sASS 하지 않아도 된다.
                    // 하지만 bookmarkData 생성한 url 에서 다시 bookmarkData 생성할 경우도 있으니 하긴 해야할 듯.

                    // let accessing = url.startAccessingSecurityScopedResource()
                    // defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                    // print("data: accessing, \(accessing)")

                    // bookmarkData 만들려면 Project -> Signing & Capabilities -> File Access 에 Read/Write 를 줘야 한다;
                    // ReadOnly 상태에서는 오류가 난다.

                    let bookmarkData = try url.bookmarkData(options: [.withSecurityScope])
                    UserDefaults.standard.set(bookmarkData, forKey: "SecurityScopedTest")
                }

                print("testSecurityScoped: all succeed")
            } catch {
                print("testSecurityScoped: fail, \(error.localizedDescription)")
            }
        }
    }

    func testBookmark() {
        do {
            guard let bookmarkData = UserDefaults.standard.data(forKey: "SecurityScopedTest") else { return }

            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData,
                              options: .withSecurityScope,
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)

            print("testSecurityScopedBookmark: isStale == \(isStale)")

            do {
                // 앱을 재 실행하고 BookmarkData 에서 URL을 새로 만들어 접근하려고 하면 퍼미션 에러가 난다.
                // 이 때야 말로 정말 sASS 가 필요하다.

                // let accessing = url.startAccessingSecurityScopedResource()
                // defer { if accessing { url.stopAccessingSecurityScopedResource() } }

                // print("testBookmark: start file accessing")
                // _ = try Data(contentsOf: url)
            }

            do {
                // 이 방식은 쓰면 안 될 듯.
                // Object 가 바로 deinit 된다;
                // let _ = SecurityScope(for: url)

                // ...
            }

            do {
                // 이 방식은 잘 동작한다.
                // let securityScope = SecurityScope(for: url)
                // defer { securityScope.stopAccessing() }

                // print("testBookmark: start file accessing")

                // _ = try Data(contentsOf: url)
            }

            do {
                // 이 방식도 잘 동작한다.

                try withSecurityScope(url) {
                    _ = try Data(contentsOf: url)
                }
            }

            print("testSecurityScopedBookmark: all succeed")
        } catch {
            print("testSecurityScopedBookmark: fail, \(error.localizedDescription)")
        }
    }

    func testBookmark2() {
        do {
            guard let bookmarkData = UserDefaults.standard.data(forKey: "SecurityScopedTest") else { return }

            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData,
                              options: .withSecurityScope,
                              relativeTo: nil,
                              bookmarkDataIsStale: &isStale)

            // 앱을 재 실행하고 BookmarkData 에서 URL을 새로 만들어 접근하려고 하면 퍼미션 에러가 난다.
            // 이 때야 말로 정말 sASS 가 필요하다.

            // testBookmark 에서 access 에 한번 성공한 후에도
            // testBookmark2 는 계속 실패한다.
            // bookmark 에서 만든 URL에 접근할 때마다 sASS 를 해야 한다.

            // let accessing = url.startAccessingSecurityScopedResource()
            // defer { if accessing { url.stopAccessingSecurityScopedResource() } }

            _ = try Data(contentsOf: url)

            print("testSecurityScopedBookmark2: all succeed")
        } catch {
            print("testSecurityScopedBookmark2: fail, \(error.localizedDescription)")
        }
    }
}
