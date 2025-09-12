//
//  Storage.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/09/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation

/// Storage helper methods.
public struct Storage {
    public static var libraryDirectory: URL {
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    }

    public static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    public static var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    public static var tempDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    /// Creates directory for the specified URL.
    public static func createDirectory(url: URL) {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }

    /// Calculates relative path from one URL to another.
    public static func relativePath(from: URL, to: URL) -> String {
        let basePath = from.path
        var path = to.path
        if let range = path.range(of: basePath) {
            path = String(path[range.upperBound...])
        }
        return path
    }

    public static let libraryScheme = "library"
    public static let documentsScheme = "documents"
    public static let cachesScheme = "cache"

    public static let schemeDirectories: [String: URL] = [
        libraryScheme: libraryDirectory,
        documentsScheme: documentsDirectory,
        cachesScheme: cachesDirectory,
    ]
}
