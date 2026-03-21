//
//  Action.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 3/7/26.
//

import Foundation
import SwiftUI

enum Action: Codable {
    case openFiles, openRecent
}

struct performActionKey: FocusedValueKey {
    typealias Value = (Action) -> Void
}

extension FocusedValues {
    var performAction: performActionKey.Value? {
        get { self[performActionKey.self] }
        set { self[performActionKey.self] = newValue }
    }
}
