//
//  InsuranceEventReportCell
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsuranceEventReportCell: UITableViewCell {
    static let id: Reusable<InsuranceEventReportCell> = .fromNib()

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var eventNumberLabel: UILabel!
    @IBOutlet private var dotLabel: UILabel!
	@IBOutlet var accessoryImageView: UIImageView!
	
	override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.numberOfLines = 0
        descriptionLabel <~ Style.Label.primarySubhead
        eventNumberLabel <~ Style.Label.secondarySubhead
        dateLabel <~ Style.Label.secondarySubhead
        dotLabel <~ Style.Label.secondarySubhead
		
		accessoryImageView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
    }

    func set(title: String, description: String, date: String, eventNumber: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        eventNumberLabel.text = eventNumber
        dateLabel.text = date
    }
}
