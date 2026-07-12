//
//  BrowserSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserSheet: ViewModifier {
    @Environment(BrowserState.self) var browserState

    func body(content: Content) -> some View {
        @Bindable var browserState = browserState
        content
            .sheet(isPresented: $browserState.isNewFileSheetPresented) {
                NewFileSheet()
            }
            .sheet(isPresented: $browserState.renameState.isRenameSheetPresented) {
                RenameSheet()
            }
            .alert("", isPresented: $browserState.alertState.hasMessage) {
                Button("OK") { }
            } message: {
                Text(browserState.alertState.message)
            }
    }
}
