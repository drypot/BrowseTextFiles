//
//  TextFileView.swift
//  TextApp
//
//  Created by Kyuhyun Park on 7/7/25.
//

import SwiftUI

struct TextFileView: View {
    let url: URL?
    @State private var content: String = "..."

    var body: some View {
        ScrollView {
            Text(content)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            loadFile()
        }
        .onChange(of: url) {
            loadFile()
        }
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
