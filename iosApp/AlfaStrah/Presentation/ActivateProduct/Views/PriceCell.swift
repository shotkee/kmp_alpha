//
//  PriceCell.swift
//  AlfaStrah
//
//  Created by Igor Bulyga on 24.08.15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class PriceCell: UITableViewCell {
    static var id: Reusable<PriceCell> = .fromNib()
    @IBOutlet private var availablePriceLabel: UILabel!
    @IBOutlet private var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .Background.backgroundSecondary
		
        availablePriceLabel <~ Style.Label.primaryHeadline1
		separatorView.backgroundColor = .Stroke.divider
    }

    func setPrice(_ price: String) {
        availablePriceLabel.text = price
    }
}
