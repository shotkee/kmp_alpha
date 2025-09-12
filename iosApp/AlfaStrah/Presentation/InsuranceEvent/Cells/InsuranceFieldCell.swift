//
//  InsuranceFieldCell
//  AlfaStrah
//
// Created by Roman Churkin on 03/08/15.
// Copyright (c) 2015 RedMadRobot. All rights reserved.
//

import UIKit

class InsuranceFieldCell: UITableViewCell {
	@IBOutlet private var titleLabel: UILabel! 
	@IBOutlet private var infoLabel: UILabel!
	
    @IBOutlet private var iconImageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        infoLabel.text = nil
        iconImageView.image = nil
    }

    func configureForModel(_ viewModel: InsuranceFieldViewModel) {
        titleLabel.text = viewModel.title
        infoLabel.text = viewModel.info
		
		titleLabel <~ Style.Label.primaryHeadline1
		infoLabel <~ Style.Label.primaryText

        if viewModel.insuranceField.type == .link {
            infoLabel.textColor = Style.Color.Palette.blue
        } else {
            infoLabel.textColor = Style.Color.Palette.black
        }
    }
}
