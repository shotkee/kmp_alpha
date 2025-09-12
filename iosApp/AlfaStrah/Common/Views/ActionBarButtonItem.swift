//
// ActionBarButtonItem
// AlfaStrah
//
// Created by Eugene Egorov on 07 December 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit

class ActionBarButtonItem: UIBarButtonItem {
    var actionClosure: (() -> Void)? {
        didSet {
            target = self
            action = #selector(fireActionClosure)
        }
    }

    @objc private func fireActionClosure() {
        actionClosure?()
    }
}
