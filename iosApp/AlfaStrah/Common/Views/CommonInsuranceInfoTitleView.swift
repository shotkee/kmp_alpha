//
//  CommonInsuranceInfoTitleView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class CommonInsuranceInfoTitleView: UIView {
    @IBOutlet private var viewTitleLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
		backgroundColor = .Background.backgroundSecondary
		
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Style.Margins.defaultInsets
        viewTitleLabel <~ Style.Label.tertiaryCaption1
        titleLabel <~ Style.Label.primaryHeadline1
        subtitleLabel <~ Style.Label.primaryCaption1
        viewTitleLabel.text = NSLocalizedString("common_insurance_title", comment: "")
    }

    func set(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
