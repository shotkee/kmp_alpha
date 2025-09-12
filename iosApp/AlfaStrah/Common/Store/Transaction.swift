//
// Transaction
// AlfaStrah
//
// Created by Eugene Egorov on 04 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

typealias Transaction = ReadTransaction & WriteTransaction

protocol ReadTransaction {
    func select<T: Entity>() throws -> [T]
    func select<T: Entity>(id: String) throws -> T?
    func select<T: Entity>(predicate: NSPredicate) throws -> [T]
}

protocol WriteTransaction {
    func insert<T: Entity>(_ object: T) throws
    func insert<T: Entity>(_ objects: [T]) throws

    func update<T: Entity>(_ object: T) throws
    func update<T: Entity>(_ objects: [T]) throws

    func upsert<T: Entity>(_ object: T) throws
    func upsert<T: Entity>(_ objects: [T]) throws

    func delete<T: Entity>(type: T.Type) throws
    func delete<T: Entity>(type: T.Type, id: String) throws
    func delete<T: Entity>(type: T.Type, predicate: NSPredicate) throws
}
