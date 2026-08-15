//
//  Styler.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/29/26.
//

import SwiftUI

final class Styler {

    static let shared = Styler()

    private init() {}

    func foregroundStyleWhen(selected: Bool, active: Bool) -> Color {
        if selected {
            if active {
                Color(nsColor: .selectedMenuItemTextColor)
            } else {
                Color(nsColor: .secondaryLabelColor)
            }
        } else {
            Color(nsColor: .secondaryLabelColor)
        }
    }

    func backgroundStyleWhen(selected: Bool, active: Bool) -> Color {
        if selected {
            if active {
                Color(nsColor: .selectedContentBackgroundColor)
            } else {
                Color(nsColor: .unemphasizedSelectedContentBackgroundColor)
            }
        } else {
            Color(nsColor: .clear)
        }
    }

}
