//
//  Test.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 4/6/26.
//

import Foundation
import Testing

struct Test {

    let tempFileContent = "..."

    func getOrCreateTempFile() throws -> URL {
        let fileManager = FileManager.default

        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("testSecurityScoped.txt")

        if !fileManager.fileExists(atPath: fileURL.path) {
            try tempFileContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("new temp file created")
        } else {
            print("reuse temp file")
        }

        return fileURL
    }

    @Test func testSecurityScoped() throws {

        let url = try getOrCreateTempFile()

        let bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil)

        var isStale = false
        let securityURL = try URL(resolvingBookmarkData: bookmarkData,
                                  options: .withSecurityScope,
                                  relativeTo: nil,
                                  bookmarkDataIsStale: &isStale )

        // Sandbox 안에서 테스트해야 해서, Unit Test 로는 어려움이 있겠다.
        // 그냥 앱 본체에 Menu, NSOpenPanel 조합 하나 만들어서 수작업 테스트해야겠다.
        // 여기 작업은 일단 중지.

        // 4. 접근 시작 및 검증
//        let accessStarted = securityURL.startAccessingSecurityScopedResource()
//        #expect(accessStarted == true, "보안 리소스 접근 시작에 실패했다.")
//
//        // 파일 읽기 가능 확인
        #expect(try String(contentsOf: securityURL, encoding: .utf8) == tempFileContent)
//
//        // 5. 접근 종료 테스트
//        securityURL.stopAccessingSecurityScopedResource()
//
//        // 6. 종료 후 접근 시도 (권한 에러 발생 확인)
//        // 시스템이 즉시 권한을 회수하므로, 다시 읽기를 시도하면 에러가 발생해야 한다.
//        #expect(throws: (any Error).self) {
//            try String(contentsOf: securityURL)
//        }
//
//        // 임시 파일 삭제
//        try? fileManager.removeItem(at: securityURL)
    }

}
