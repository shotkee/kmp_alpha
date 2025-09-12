//
// RealmTransaction
// AlfaStrah
//
// Created by Eugene Egorov on 04 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

enum RealmError: Error {
    case noTransformer
    case typeMismatch
    case noEntity
}

class RealmTransaction: Transaction {
    private let realm: Realm
    private let mapper: RealmMapper

    init(realm: Realm, mapper: RealmMapper) {
        self.realm = realm
        self.mapper = mapper
    }

    // MARK: - Select

    func select<T: Entity>() throws -> [T] {
        try internalSelect(predicate: nil, offset: 0, limit: nil)
    }

    func select<T: Entity>() throws -> [T] where T: Equatable {
        try internalSelect(predicate: nil, offset: 0, limit: nil)
    }

    func select<T: Entity>(id: String) throws -> T? {
        try internalSelect(predicate: NSPredicate(format: "id = %@", id), offset: 0, limit: 1).first
    }

    func select<T: Entity>(predicate: NSPredicate) throws -> [T] {
        try internalSelect(predicate: predicate, offset: 0, limit: nil)
    }

    private func internalSelect<T: Entity>(predicate: NSPredicate?, offset: Int, limit: Int?) throws -> [T] {
        let transformer: RealmTransformer<T> = try mapper.transformer()
        var resultArray: [T] = []
        var currentOffset: Int = 0
        var result = realm.objects(transformer.objectType)
        if let predicate = predicate {
            result = result.filter(predicate)
        }
        for realmEntity in result {
            currentOffset += 1
            if currentOffset <= offset {
                continue
            }
            let entity = try transformer.transform(object: realmEntity)
            resultArray.append(entity)
            if let limit = limit, resultArray.count >= limit {
                break
            }
        }
        return resultArray
    }

    // MARK: - Insert

    func insert<T: Entity>(_ object: T) throws {
        try insert([ object ])
    }

    func insert<T: Entity>(_ objects: [T]) throws {
        let transformer: RealmTransformer<T> = try mapper.transformer()
        let realmEntities = try objects.map(transformer.transform(entity:))
        realm.add(realmEntities, update: .error)
    }

    // MARK: - Update

    func update<T: Entity>(_ object: T) throws {
        try update([ object ])
    }

    func update<T: Entity>(_ objects: [T]) throws {
        let transformer: RealmTransformer<T> = try mapper.transformer()
        let realmEntities = try objects.map(transformer.transform(entity:))
        realm.add(realmEntities, update: .all)
    }

    // MARK: - Update or insert

    func upsert<T: Entity>(_ object: T) throws {
        try update([ object ])
    }

    func upsert<T: Entity>(_ objects: [T]) throws {
        try update(objects)
    }

    // MARK: - Delete

    func delete<T: Entity>(type: T.Type) throws {
        try internalDelete(type: type, predicate: nil)
    }

    func delete<T: Entity>(type: T.Type, id: String) throws {
        try internalDelete(type: type, predicate: NSPredicate(format: "id = %@", id))
    }

    func delete<T: Entity>(type: T.Type, predicate: NSPredicate) throws {
        try internalDelete(type: type, predicate: predicate)
    }

    private func internalDelete<T: Entity>(type: T.Type, predicate: NSPredicate?) throws {
        let transformer: RealmTransformer<T> = try mapper.transformer()
        var result = realm.objects(transformer.objectType)
        if let predicate = predicate {
            result = result.filter(predicate)
        }
        realm.delete(result)
    }
}
