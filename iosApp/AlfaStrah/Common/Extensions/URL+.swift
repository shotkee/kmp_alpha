//
//  URL+.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UniformTypeIdentifiers

extension URL {
	var isImageFile: Bool {
		if #available(iOS 14.0, *) {
			return UTType(filenameExtension: pathExtension)?.conforms(to: .image) ?? false
		} else {
			return isImageFileURL(self)
		}
	}
	
	private static let imageFileExtensions: [String] = [
		"png",
		"jpeg",
		"jpg",
		"tif",
		"tiff",
		"heic",
		"heif",
		"bmp",
		"gif"
	]
	
	private func isImageFileURL(_ url: URL?) -> Bool {
		guard let pathExtention = url?.pathExtension
		else { return false }
		
		return Self.imageFileExtensions.contains(pathExtention)
	}
	
	func resourceSize() -> Int64? {
		let resource = try? self.resourceValues(forKeys: [.fileSizeKey])
		
		if let size = resource?.fileSize {
			return Int64(size)
		}
		return nil
	}
}
