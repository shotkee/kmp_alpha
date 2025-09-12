//
//  Debouncer.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 28.01.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation

class Debouncer {
    private let queue = DispatchQueue.main
    private var workItem: DispatchWorkItem = DispatchWorkItem {}
    private var interval: Int

    init(milliseconds: Int) {
        self.interval = milliseconds
    }

    func debounce(action: @escaping () -> Void) {
        workItem.cancel()
        workItem = DispatchWorkItem(block: action)
        queue.asyncAfter(
            deadline: DispatchTime.now() + Double(interval / 1000),
            execute: workItem
        )
    }
}
