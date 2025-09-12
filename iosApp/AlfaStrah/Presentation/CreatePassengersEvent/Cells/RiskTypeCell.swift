//
//  RiskTypeCell.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 11/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class RiskTypeCell: UITableViewCell {
    static let cellId: Reusable<RiskTypeCell> = .fromNib()

    var risk: Risk? {
        didSet {
			eventTypeTitleLabel <~ Style.Label.primaryHeadline1
            eventTypeTitleLabel.text = risk?.title
        }
    }

    enum State {
        case normal
        case disabled
    }

    var state: State = .normal {
        didSet {
            updateState()
        }
    }

    var marked: Bool = false {
        didSet {
            iconView.isHidden = !marked
        }
    }

	@IBOutlet private var eventTypeTitleLabel: UILabel!
	
    @IBOutlet private var iconView: UIImageView!

    private func updateState() {
        switch state {
            case .normal:
				eventTypeTitleLabel.textColor = .Text.textPrimary
            case .disabled:
                eventTypeTitleLabel.textColor = .Text.textSecondary
        }
    }
}
