//
// Store
// AlfaStrah
//
// Created by Eugene Egorov on 04 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

protocol Store {
    func read(_ block: (ReadTransaction) throws -> Void) throws
    func write(_ block: (Transaction) throws -> Void) throws
}
