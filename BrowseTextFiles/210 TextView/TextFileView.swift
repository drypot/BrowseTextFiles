//
//  TextFileView.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/7/25.
//

import SwiftUI

struct TextFileView: View {
    let url: URL?
    @State private var content: String = "..."

    @Environment(AppSettings.self) var settings

    var body: some View {
//        ScrollView {
//            TextEditor(text: $content)
//            Text(content)
//                .font(.custom(settings.fontName, size: settings.fontSize))
//                .lineSpacing(settings.lineSpacing)
//                .padding()
//                .frame(maxWidth: .infinity, alignment: .leading)
//        }
        CustomTextEditor(text: $content)
            .padding(32)
            .background(Color(.textBackgroundColor))
//            .frame(minWidth: 400, minHeight: 400, maxHeight: .infinity)
//                        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear(perform: loadFile)
        .onChange(of: url, loadFile)
    }

    private func loadFile() {
        guard let url else { return }

        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            content = "An error occurred while reading the file:\n\(error.localizedDescription)"
        }
    }

}
