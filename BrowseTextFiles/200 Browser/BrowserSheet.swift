//
//  BrowserSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserSheet: ViewModifier {
    @Environment(BrowserState.self) var state

    func body(content: Content) -> some View {
        @Bindable var state = state
        content
            .sheet(isPresented: $state.isNewFileWithTemplatePresented) {
                NewFileWithTemplateSheet()
            }
            .sheet(isPresented: $state.isRenameFilePresented) {
                RenameFileSheet()
            }
            .sheet(isPresented: $state.isRenameFolderPresented) {
                RenameFolderSheet()
            }
            .alert("", isPresented: $state.context.hasAlertMessage) {
                Button("OK") { }
            } message: {
                Text(state.context.alertMessage)
            }
    }
}
