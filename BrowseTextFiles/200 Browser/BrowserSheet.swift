//
//  BrowserSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserSheet: ViewModifier {
    @Environment(BrowserState.self) var browser

    func body(content: Content) -> some View {
        @Bindable var browser = browser
        content
            .sheet(isPresented: $browser.isNewFileWithTemplatePresented) {
                NewFileWithTemplateSheet()
            }
            .sheet(isPresented: $browser.isRenameFilePresented) {
                RenameFileSheet()
            }
            .sheet(isPresented: $browser.isRenameFolderPresented) {
                RenameFolderSheet()
            }
            .alert("", isPresented: $browser.context.hasAlertMessage) {
                Button("OK") { }
            } message: {
                Text(browser.context.alertMessage)
            }
    }
}
