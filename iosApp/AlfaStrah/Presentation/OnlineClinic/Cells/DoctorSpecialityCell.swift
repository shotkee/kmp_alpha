//
//  DoctorKindCell.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 07/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation
import Legacy

class DoctorSpecialityCell: UITableViewCell {
    static let id: Reusable<DoctorSpecialityCell> = .fromClass()

	@IBOutlet private var accessoryImageView: UIImageView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var cardView: CardView!

    override func awakeFromNib() {
        super.awakeFromNib()
		
		clearStyle()
		cardView.contentColor = .Background.backgroundSecondary
        
        titleLabel <~ Style.Label.primaryText
        titleLabel.text = ""
    }

    func set(title: String) {
        titleLabel.text = title
    }
}
