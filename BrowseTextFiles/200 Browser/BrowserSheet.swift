//
//  BrowserSheet.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/12/26.
//

import SwiftUI

struct BrowserSheet: ViewModifier {
    @Environment(RootState.self) var rootState

    func body(content: Content) -> some View {
        @Bindable var rootState = rootState
        content
            .sheet(isPresented: $rootState.isNewFileSheetPresented) {
                NewFileSheet()
            }
            .sheet(isPresented: $rootState.isRenameSheetPresented) {
                RenameSheet()
            }
            .alert("", isPresented: $rootState.browserState.hasAlertMessage) {
                Button("OK") { }
            } message: {
                Text(rootState.browserState.alertMessage)
            }
    }
}
