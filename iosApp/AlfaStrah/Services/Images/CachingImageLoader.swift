//
//  CachingImageLoader.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/09/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

/// Caching image loader.
class CachingImageLoader: ImageLoader {
    let name: String
    private let imageLoader: ImageLoader
    private let cache: NSCache<NSString, UIImage>
    private let cacheDirectory: URL

    init(name: String, imageLoader: ImageLoader) {
        self.name = name
        self.imageLoader = imageLoader

        cache = NSCache()
        cacheDirectory = Storage.cachesDirectory.appendingPathComponent(name, isDirectory: true)
        Storage.createDirectory(url: cacheDirectory)
    }

    /// Loads an avatar image from url.
    /// Completion can be called twice: for cached image and for requested from underlying image loader.
    @discardableResult
    func load(url: URL, size: CGSize, mode: ResizeMode, completion: @escaping ImageLoaderCompletion) -> ImageLoaderTask {
        let canBeCached = url.scheme == "http" || url.scheme == "https"
        let key = "\(url.absoluteString.sha1.hexadecimal)_\(Int(size.width))_\(Int(size.height))_\(mode)"
        let nsKey = key as NSString
        let fileUrl = cacheDirectory.appendingPathComponent(key, isDirectory: false)

        if canBeCached {
            if let image = cache.object(forKey: nsKey), let data = image.jpegData(compressionQuality: 0.5) {
                completion(.success((data, image)))
                return Task(url: url, size: size, mode: mode)
            } else if let data = try? Data(contentsOf: fileUrl), let image = UIImage(data: data) {
                cache.setObject(image, forKey: nsKey)
                completion(.success((data, image)))
                return Task(url: url, size: size, mode: mode)
            }
        }

        return imageLoader.load(url: url, size: size, mode: mode) { result in
            if canBeCached, let data = result.value?.0, let image = result.value?.1 {
                self.cache.setObject(image, forKey: nsKey)
                try? data.write(to: fileUrl)
            }

            completion(result)
        }
    }
}

private class Task: ImageLoaderTask {
    var url: URL
    var size: CGSize
    var mode: ResizeMode

    func cancel() { }

    init(url: URL, size: CGSize, mode: ResizeMode) {
        self.url = url
        self.size = size
        self.mode = mode
    }
}
