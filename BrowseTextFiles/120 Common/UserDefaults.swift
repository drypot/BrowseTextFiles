//
//  UserDefaults.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 6/20/26.
//

import Foundation

extension UserDefaults {
    func double(forKey key: String, defaultValue: Double) -> Double {
        if UserDefaults.standard.object(forKey: key) == nil {
            defaultValue
        } else {
            UserDefaults.standard.double(forKey: key)
        }
    }

    func integer(forKey key: String, defaultValue: Int) -> Int {
        if UserDefaults.standard.object(forKey: key) == nil {
            defaultValue
        } else {
            UserDefaults.standard.integer(forKey: key)
        }
    }

    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if UserDefaults.standard.object(forKey: key) == nil {
            defaultValue
        } else {
            UserDefaults.standard.bool(forKey: key)
        }
    }

    func string(forKey key: String, defaultValue: String) -> String {
        UserDefaults.standard.string(forKey: key) ?? defaultValue
    }

    func stringArray(forKey key: String, defaultValue: [String], minSize: Int = 0) -> [String] {
        var strings = UserDefaults.standard.stringArray(forKey: key) ?? defaultValue
        while strings.count < minSize {
            strings.append("")
        }
        return strings
    }
}
