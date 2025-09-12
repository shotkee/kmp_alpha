//
//  RiskDocumentCell.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 21/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class RiskDocumentCell: UITableViewCell {
    static let id: Reusable<RiskDocumentCell> = .fromNib()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }

    enum Status {
        case ready
        case optional
        case required
    }

    var status: Status = .optional {
        didSet {
            switch status {
                case .ready:
                    iconView.tintColor = Style.Color.Palette.green
                case .required:
                    iconView.tintColor = Style.Color.Palette.red
                case .optional:
                    iconView.tintColor = Style.Color.Palette.gray
            }
        }
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()

		setupUI()
	}
	
	private func setupUI() {
		if let titleLabel {
			titleLabel <~ Style.Label.primaryHeadline1
		}
		
		if let subtitleLabel {
			subtitleLabel <~ Style.Label.secondaryText
		}
	}
}
