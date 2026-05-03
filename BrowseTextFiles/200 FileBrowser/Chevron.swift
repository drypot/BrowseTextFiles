//
//  Chevron.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/3/26.
//

import SwiftUI

struct Chevron: View {
    let hasChildren: Bool
    let isExpaned: Bool
    let onTap: () -> Void

    var body: some View {
        if hasChildren {
            Group {
                if isExpaned {
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "chevron.forward")
                        .resizable()
                        .scaledToFit()
                }
            }
            .bold()
            .frame(width: 9, height: 9)
            .onTapGesture(perform: onTap)
        } else {
            Spacer()
                .frame(width: 9)
        }
    }
}
