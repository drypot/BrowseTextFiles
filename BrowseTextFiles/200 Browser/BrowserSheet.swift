//
//  BrowserSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserSheet: ViewModifier {
    @Environment(BrowserStateRoot.self) var stateRoot

    func body(content: Content) -> some View {
        @Bindable var stateRoot = stateRoot
        content
            .sheet(isPresented: $stateRoot.isNewFileWithTemplatePresented) {
                NewFileWithTemplateSheet()
            }
            .sheet(isPresented: $stateRoot.isRenameFilePresented) {
                RenameFileSheet()
            }
            .sheet(isPresented: $stateRoot.isRenameFolderPresented) {
                RenameFolderSheet()
            }
            .alert("", isPresented: $stateRoot.browserState.hasAlertMessage) {
                Button("OK") { }
            } message: {
                Text(stateRoot.browserState.alertMessage)
            }
    }
}
