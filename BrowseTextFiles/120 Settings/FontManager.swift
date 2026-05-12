//
//  FontManager.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/12/26.
//

import AppKit

final class FontManager: NSObject {
    private var currentFont: NSFont?
    private var onChange: ((NSFont) -> Void)?

    func showFontPanel(initialFont: NSFont, onChange: @escaping (NSFont) -> Void) {
        self.currentFont = initialFont
        self.onChange = onChange

        let manager = NSFontManager.shared
        manager.target = self
        manager.action = #selector(changeFont(_:))

        NSFontPanel.shared.setPanelFont(initialFont, isMultiple: false)
        NSFontPanel.shared.makeKeyAndOrderFront(nil)
    }

    @objc func changeFont(_ sender: Any?) {
        guard let manager = sender as? NSFontManager else { return }
        guard let currentFont else { return }
        guard let onChange else { return }

        let newFont = manager.convert(currentFont)
        self.currentFont = newFont
        onChange(newFont)
    }
}
