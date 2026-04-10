//
//  TextBrowserReady.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 4/6/26.
//

import SwiftUI

struct TextBrowserReady: View {
    @Bindable var status: TextBrowserStatus

    var body: some View {
        HSplitView {
            List(status.folders, children: \.folders, selection: $status.selectedFolder) { folder in
                NavigationLink(folder.name, value: folder)
            }
            .frame(minWidth: 180, idealWidth: 260)

            List(status.fileURLs, id: \.self, selection: $status.selectedFileURL) { file in
                NavigationLink(file.lastPathComponent, value: file)
            }
            .frame(minWidth: 180, idealWidth: 260)

            Group {
                if let buffer = status.buffer,
                   buffer.isValid {
                    TextEditor2(buffer: buffer)
                } else {
                    Spacer()
                }
            }
            .frame(minWidth: 300, maxWidth: .infinity)
            .layoutPriority(1)
        }
        .onChange(of: status.selectedFolder) {
            status.refreshFiles()
        }
        .onChange(of: status.selectedFileURL) {
            status.openSelectedFile()
        }

    }
}

#Preview {
    // TextBrowserReady()
}
