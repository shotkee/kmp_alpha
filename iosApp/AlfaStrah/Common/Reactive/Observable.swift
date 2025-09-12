//
// Observable
// AlfaStrah
//
// Created by Eugene Egorov on 15 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import Legacy

struct Observable<Value: Equatable> {
    typealias Listener = (Value) -> Void

    var value: Value {
        didSet {
            if !skipSameValue || oldValue != value {
                subscriptions.fire(value)
            }
        }
    }

    private let skipSameValue: Bool
    private var subscriptions: Subscriptions<Value> = Subscriptions()

    init(value: Value, skipSameValue: Bool = true) {
        self.value = value
        self.skipSameValue = skipSameValue
    }

    mutating func subscribe(immediatelyFire: Bool = false, listener: @escaping Listener) -> Subscription {
        if !isKnownUniquelyReferenced(&subscriptions) {
            subscriptions = subscriptions.copy
        }
        if immediatelyFire {
            listener(value)
        }
        return subscriptions.add(listener)
    }
}
