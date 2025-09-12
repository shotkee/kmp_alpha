//
//  RadioControlElementCell.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 12/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class RadioControlElementCell: UITableViewCell {
    static let cellId: Reusable<RadioControlElementCell> = .fromNib()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var marked: Bool = false {
        didSet {
            iconView.image = marked ? UIImage(named: "radiobuttonOnRed") : UIImage(named: "radiobuttonOffRed")
        }
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()

		setupUI()
	}
	
	private func setupUI() {
		if let titleLabel {
			titleLabel <~ Style.Label.primaryHeadline1
		}
	}
}
