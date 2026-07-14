//
//  BrowserState.swift
//  Browse Text Files
//
//  Created by Kyuhyun Park on 7/7/26.
//

import SwiftUI

@Observable
final class BrowserState {

    // MARK: - ID

    let id = UUID()
    weak var window: NSWindow?

    // MARK: - Root

    private(set) var rootURL: URL?
    private(set) var rootName: String?
    private(set) var rootPath: String?
    private var shouldReleaseSecurityScopedResource = false

    // MARK: - Status

    enum BrowserStatus {
        case showOpenPanel
        case loading
        case ready
    }

    var status: BrowserStatus = .loading

    // MARK: - Sidebar Status

    enum SidebarStatus: String, Identifiable, CaseIterable {
        case folder = "Folder"
        case history = "History"
        case find = "Find"

        var id: String {
            self.rawValue
        }

        var imageName: String {
            switch self {
            case .folder: return "folder"
            case .history: return "clock"
            case .find: return "magnifyingglass"
            }
        }
    }

    var sidebarStatus: SidebarStatus = .folder

    // MARK: - Folder

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

    // MARK: - File

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

    // MARK: - Alert

    var alertMessage: String = ""
    var hasAlertMessage = false

    // MARK: - Root

    func configure(with rootURL: URL) {
        self.rootURL = rootURL
        self.rootName = rootURL.lastPathComponent
        self.rootPath = rootURL.path(percentEncoded: false)
        self.shouldReleaseSecurityScopedResource = rootURL.startAccessingSecurityScopedResource()
    }

    func releaseResource() {
        guard let rootURL else { return }
        if shouldReleaseSecurityScopedResource {
            rootURL.stopAccessingSecurityScopedResource()
            shouldReleaseSecurityScopedResource = false
        }
    }

    // MARK: - Alert

    func leaveAlert(_ message: String) {
        self.alertMessage = message
        self.hasAlertMessage = true
    }

}
