//
//  UTType.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 4/7/26.
//

import UniformTypeIdentifiers

/*
    Project -> Target -> Info -> Document Types 에 가서 + 누르면 Info.plist 가 생성된다.
    Info.plist 소스로 열어서 복사해 넣는다.

    OS 와 Text File Type 연결이 당장은 필요 없어서 빼놓았다.

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>CFBundleDocumentTypes</key>
        <array>
            <dict>
                <key>CFBundleTypeName</key>
                <string>Text File</string>
                <key>CFBundleTypeRole</key>
                <string>Editor</string>
                <key>LSHandlerRank</key>
                <string>Alternate</string>
                <key>LSItemContentTypes</key>
                <array>
                    <string>public.plain-text</string>
                </array>
            </dict>
        </array>
    </dict>
    </plist>

*/

extension UTType {
//    nonisolated public static let gpx: UTType = UTType(importedAs: "com.topografix.gpx")
//    nonisolated public static let gpxInternal: UTType = UTType(exportedAs: "com.drypot.internal-gpx")
}
