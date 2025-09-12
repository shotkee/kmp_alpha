//
// DisposeBag
// AlfaStrah
//
// Created by Eugene Egorov on 15 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import Legacy

class DisposeBag {
    private var subscriptions: [Subscription] = []
    private var networkTasks: [NetworkTask] = []

    func add(_ subscription: Subscription) {
        subscriptions.append(subscription)
    }

    func add(_ networkTask: NetworkTask) {
        networkTasks.append(networkTask)
    }

    deinit {
        networkTasks.forEach { $0.cancel() }
    }
}

extension Subscription {
    func disposed(by disposeBag: DisposeBag) {
        disposeBag.add(self)
    }
}

extension NetworkTask {
    func disposed(by disposeBag: DisposeBag) {
        disposeBag.add(self)
    }
}
