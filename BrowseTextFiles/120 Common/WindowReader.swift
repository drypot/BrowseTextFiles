//
//  WindowReader.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/7/25.
//

import SwiftUI

struct WindowReader: NSViewRepresentable {
    var onResolve: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.onResolve(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) { }
}
