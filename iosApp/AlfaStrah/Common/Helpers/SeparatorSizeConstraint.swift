//
// SeparatorSizeConstraint
// AlfaStrah
//
// Created by Eugene Egorov on 16 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import UIKit

class SeparatorSizeConstraint: NSLayoutConstraint {
    override func awakeFromNib() {
        super.awakeFromNib()

        constant = 1.0 / UIScreen.main.scale
    }
}
