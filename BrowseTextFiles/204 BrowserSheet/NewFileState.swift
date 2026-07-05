//
//  NewFileState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/6/26.
//

import SwiftUI

@Observable
final class NewFileState {
    @ObservationIgnored
    private(set) var alertState: AlertState

    init(alertState: AlertState) {
        self.alertState = alertState
    }
}
