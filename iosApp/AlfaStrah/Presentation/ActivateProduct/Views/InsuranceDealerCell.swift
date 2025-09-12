//
//  InsuranceDealerCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/22/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsuranceDealerCell: UITableViewCell {
    static var id: Reusable<InsuranceDealerCell> = .fromClass()
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    func configure(title: String) {
        titleLabel.text = title
    }

    private func setupStyle() {
		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
        titleLabel <~ Style.Label.primaryText
		separator.backgroundColor = .Stroke.divider
    }
}
