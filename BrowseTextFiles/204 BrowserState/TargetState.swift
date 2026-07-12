//
//  TargetState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/10/26.
//

import SwiftUI

@Observable
final class TargetState {

    // Folder

    private var _selectedFolderURL: URL?

    var selectedFolderURLs: Set<URL> = [] {
        didSet {
            if  selectedFolderURLs.count == 0 {
                _selectedFolderURL = nil
            } else if selectedFolderURLs.count == 1 {
                _selectedFolderURL = selectedFolderURLs.first
            }
        }
    }

    var selectedFolderURL: URL? {
        get {
            _selectedFolderURL
        }

        set {
            if let newValue {
                selectedFolderURLs = [newValue]
            } else {
                selectedFolderURLs = []
            }
        }
    }

    // File

    private var _selectedFileURL: URL?

    var selectedFileURLs: Set<URL> = [] {
        didSet {
            if  selectedFileURLs.count == 0 {
                _selectedFileURL = nil
            } else if selectedFileURLs.count == 1 {
                _selectedFileURL = selectedFileURLs.first
            }
        }
    }

    var selectedFileURL: URL? {
        get {
            _selectedFileURL
        }

        set {
            if let newValue {
                selectedFileURLs = [newValue]
            } else {
                selectedFileURLs = []
            }
        }
    }

    // Utility

    func targetFile(_ fileURL: URL) {
        let folderURL = fileURL.deletingLastPathComponent()
        selectedFolderURL = folderURL
        selectedFileURL = fileURL
    }

}
