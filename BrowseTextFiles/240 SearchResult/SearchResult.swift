//
//  SearchResult.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 5/5/26.
//

import Foundation

nonisolated struct SearchResult: Identifiable {
    struct Line: Identifiable {
        let id = UUID()
        let text: String
    }
    
    let id = UUID()
    let url: URL
    let title: String
    let lines: [Line]
}
