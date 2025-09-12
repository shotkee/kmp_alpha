//
//  FileManager.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 30/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

extension FileManager {
    func fileExistsAtURL(_ url: URL) -> Bool {
        fileExists(atPath: url.path)
    }

    func createDirectoryForFileUrl(_ url: URL) {
        do {
            let directoryUrl = url.deletingLastPathComponent()
            if !fileExistsAtURL(directoryUrl) {
                try createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("error creating directory:", error)
        }
    }
}
