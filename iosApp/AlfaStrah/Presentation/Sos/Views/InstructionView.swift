//
// Created by Roman Churkin on 17/11/15.
// Copyright (c) 2015 RedMadRobot. All rights reserved.
//

import UIKit

class InstructionView: UIView {
	@IBOutlet private var titleLabel: UILabel! {
		didSet {
			titleLabel <~ Style.Label.primaryHeadline1
		}
	}
	
    @IBOutlet private var detailsLabel: UILabel! {
		didSet {
			detailsLabel <~ Style.Label.secondaryText
		}
	}

    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    var details: String? {
        get {
            detailsLabel.text
        }
        set {
            detailsLabel.text = newValue
        }
    }
}
