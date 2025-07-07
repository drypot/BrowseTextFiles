//
//  FileTextView.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/7/25.
//

import SwiftUI

struct FileTextView: View {
    let fileURL: URL
    @State private var content: String = ""

    var body: some View {
        ScrollView {
            Text(content)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear(perform: loadFile)
    }

    private func loadFile() {
        do {
            content = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            content = "An error occurred while reading the file:\n\(error.localizedDescription)"
        }
    }
}
