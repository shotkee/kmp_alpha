//
// RealmStore
// AlfaStrah
//
// Created by Eugene Egorov on 04 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import Legacy
import RealmSwift

class RealmStore: Store {
    private let mapper: RealmMapper
    private let configuration: Realm.Configuration

    init(fileUrl: URL, mapper: RealmMapper) {
        self.mapper = mapper
        self.configuration = Realm.Configuration(
            fileURL: fileUrl,
            schemaVersion: mapper.schemaVersion,
            migrationBlock: nil,
            objectTypes: mapper.objectTypes
        )
    }

    func read(_ block: (ReadTransaction) throws -> Void) throws {
        let realm = try Realm(configuration: configuration)
        let transaction = RealmTransaction(realm: realm, mapper: mapper)
        try block(transaction)
    }

    func write(_ block: (Transaction) throws -> Void) throws {
        let realm = try Realm(configuration: configuration)
        try realm.write {
            let transaction = RealmTransaction(realm: realm, mapper: mapper)
            try block(transaction)
        }
    }
}
