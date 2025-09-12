//
//  MainVzrDisclaimerView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 26/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class MainVzrDisclaimerView: UIView {
    @IBOutlet private var titleLable: UILabel!
    @IBOutlet private var subtitleLable: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
        titleLable <~ Style.Label.primaryHeadline2
        subtitleLable <~ Style.Label.secondaryText
        titleLable.text = NSLocalizedString("main_vzr_disclaimer_title", comment: "")
        subtitleLable.text = NSLocalizedString("main_vzr_disclaimer_description", comment: "")
    }
}
