//
//  TextBrowserReady.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/6/26.
//

import SwiftUI

struct TextBrowserReady: View {
    @Bindable var bufferManager: TextBufferManager

    var body: some View {
        HSplitView {
            List(bufferManager.folders, children: \.folders, selection: $bufferManager.selectedFolder) { folder in
                NavigationLink(folder.name, value: folder)
            }
            .frame(minWidth: 180, idealWidth: 260)

            List(bufferManager.files, id: \.self, selection: $bufferManager.selectedFile) { file in
                NavigationLink(file.lastPathComponent, value: file)
            }
            .frame(minWidth: 180, idealWidth: 260)

            Group {
                if let buffer = bufferManager.buffer,
                   buffer.isValid {
                    TextEditor2(buffer: buffer)
                } else {
                    Spacer()
                }
            }
            .frame(minWidth: 300, maxWidth: .infinity)
            .layoutPriority(1)
        }
        .onChange(of: bufferManager.selectedFolder) {
            bufferManager.refreshFiles()
        }
        .onChange(of: bufferManager.selectedFile) {
            bufferManager.openSelectedFile()
        }

    }
}

#Preview {
    // TextBrowserReady()
}
