//
//  PersistentConcurrent.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

class PersistentConcurrentArray<T: Codable> {
    private let fileUrl: URL
    private let queue: DispatchQueue = DispatchQueue(label: "SynchronizedArray", qos: .default, attributes: .concurrent)
    private var storage: [T] = []

    init(fileUrl: URL) {
        self.fileUrl = fileUrl

        queue.async(flags: .barrier) {
            let data = try? Data(contentsOf: fileUrl)
            self.storage = data.map { (try? JSONDecoder().decode([T].self, from: $0)) ?? [] } ?? []
        }
    }

    var values: [T] { queue.sync { storage } }

    func contains(_ predicate: (T) -> Bool) -> Bool {
        queue.sync { storage.contains { predicate($0) } }
    }

    func add(_ item: T) {
        queue.async(flags: .barrier) {
            self.storage.append(item)
            self.save()
        }
    }

    func remove(_ predicate: @escaping (T) -> Bool) {
        queue.async(flags: .barrier) {
            self.storage = self.storage.filter { !predicate($0) }
            self.save()
        }
    }

    func removeAll() {
        queue.async(flags: .barrier) {
            self.storage = []
            self.save()
        }
    }

    private func save() {
        let data = try? JSONEncoder().encode(storage)
        data.map {
            try? $0.write(to: fileUrl)
            try? (fileUrl as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
        }
    }
}

class PersistentConcurrentDictionary<T: Codable> {
    private let fileUrl: URL
    private let queue: DispatchQueue = DispatchQueue(label: "SynchronizedDictionary", qos: .default, attributes: .concurrent)
    private var storage: [Int: T] = [:]

    init(fileUrl: URL) {
        self.fileUrl = fileUrl

        queue.async(flags: .barrier) {
            let data = try? Data(contentsOf: fileUrl)
            self.storage = data.map { (try? JSONDecoder().decode([Int: T].self, from: $0)) ?? [:] } ?? [:]
        }
    }

    subscript(_ key: Int) -> T? {
        get {
            queue.sync { storage[key] }
        }
        set {
            queue.async(flags: .barrier) {
                self.storage[key] = newValue
                self.save()
            }
        }
    }

    var values: [T] { queue.sync { Array(storage.values) } }

    func containsValue(_ predicate: (T) -> Bool) -> Bool {
        queue.sync { storage.values.contains { predicate($0) } }
    }

    func removeAll() {
        queue.async(flags: .barrier) {
            self.storage = [:]
            self.save()
        }
    }

    func remove(_ valuePredicate: @escaping (T) -> Bool) {
        queue.async(flags: .barrier) {
            self.storage = self.storage.filter { _, value in !valuePredicate(value) }
            self.save()
        }
    }

    private func save() {
        let data = try? JSONEncoder().encode(storage)
        data.map {
            try? $0.write(to: fileUrl)
            try? (fileUrl as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
        }
    }
}
