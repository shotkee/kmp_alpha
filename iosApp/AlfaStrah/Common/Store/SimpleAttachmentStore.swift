//
//  SimpleAttachmentStore
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 14/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class SimpleAttachmentStore {
    private enum Constants {
        /// 0.0 to 1.0 --> 0 means maximum compression and 1 means minimum compression
        static let imageCompressionQuality: CGFloat = 0.1
    }

    private let directory: URL
    private let name: String
    let url: URL

    var exists: Bool {
        FileManager.default.fileExistsAtURL(url)
    }

    private static var sizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        formatter.allowsNonnumericFormatting = false

        return formatter
    }()

    var sizeBytes: Int64 {
        let attr = try? FileManager.default.attributesOfItem(atPath: url.path) as NSDictionary
        return Int64(attr?.fileSize() ?? 0)
    }

    var size: String {
        SimpleAttachmentStore.sizeFormatter.string(fromByteCount: sizeBytes)
    }

    init(directory: URL, name: String) {
        self.directory = directory
        self.name = name
        url = directory.appendingPathComponent(name, isDirectory: false)
    }

    func data() -> Data? {
        try? Data(contentsOf: url)
    }

    func load() -> UIImage? {
        guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else { return nil }

        return image
    }

    func save(
        _ image: UIImage,
        compressionQuality: CGFloat = Constants.imageCompressionQuality,
		errorHandler: @escaping (Error) -> Void
    ) {
        try? FileManager.default.removeItem(at: url)

        guard
            let data = image.jpegData(compressionQuality: Constants.imageCompressionQuality)
        else { return }

        Storage.createDirectory(url: directory)
        do {
            try data.write(to: url)
        } catch let error {
            errorHandler(error)
        }
    }
	
	func copyImage(
		from imageUrl: URL,
		compressionQuality: CGFloat = Constants.imageCompressionQuality,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		try? FileManager.default.removeItem(at: url)
		
		guard let imageData = try? Data(contentsOf: imageUrl),
			  let image = UIImage(data: imageData),
			  let data = image.jpegData(compressionQuality: Constants.imageCompressionQuality)
		else { return }

		Storage.createDirectory(url: directory)
		
		do {
			try data.write(to: url)
			completion(.success(()))
		} catch let error {
			completion(.failure(error))
		}
	}

    func copy(from fromUrl: URL, completion: @escaping (Result<Void, Error>) -> Void) {
		try? FileManager.default.removeItem(at: url) // ignore errors for non existing files
		
		do {
			Storage.createDirectory(url: directory)
			try FileManager.default.copyItem(at: fromUrl, to: url)
			
			completion(.success(()))
		} catch let error {
			completion(.failure(error))
		}
    }

    func save(_ data: Data) {
        try? FileManager.default.removeItem(at: url)
        Storage.createDirectory(url: directory)
        try? data.write(to: url)
    }

    func remove() {
        try? FileManager.default.removeItem(at: url)
    }
    
    static func list(directoryUrl: URL) -> [URL]? {
        try? FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
    }
}
