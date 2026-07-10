//
//  AlertState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/1/26.
//

import SwiftUI

@Observable
final class AlertState {
    var message: String = ""
    var hasMessage = false

    func leaveAlert(_ message: String) {
        self.message = message
        self.hasMessage = true
    }
}
