//
//  OSAGOCaseTypeCell.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 22.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class OSAGOCaseTypeCell: UITableViewCell {
    static let reusable = Reusable<OSAGOCaseTypeCell>.class(id: "OSAGO_TYPE_CELL")

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var hintLabel: UILabel!
    @IBOutlet private var cardView: CardView!
	@IBOutlet var accessoryImageView: UIImageView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
		titleLabel <~ Style.Label.primaryHeadline1
        hintLabel <~ Style.Label.secondaryText
		
		accessoryImageView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
		
		cardView.contentColor = .Background.backgroundSecondary
    }
    
    func set(title: String, hint: String) {
        titleLabel.text = title
        hintLabel.text = hint
    }
}
