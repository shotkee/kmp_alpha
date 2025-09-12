//
//  CancellableContainer.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 11.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

class CancellableNetworkTaskContainer {
    private var cancellables: [NetworkTask] = []

    deinit {
        cancel()
    }

    func addCancellables(_ cancellables: [NetworkTask]) {
        self.cancellables.append(contentsOf: cancellables)
    }

    func cancel() {
        cancellables.forEach { $0.cancel() }
    }
}
