//
//  CameraAutoHintOverlayView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 25/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class CameraAutoHintOverlayView: UIView {
    var closeTapHandler: (() -> Void)?

    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var groupTitleLabel: UILabel!
    @IBOutlet private var groupTtpLabel: UILabel!
    @IBOutlet private var stepTitleLabel: UILabel!
    @IBOutlet private var stepTipLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        closeButton <~ Style.Button.ActionRed(title: NSLocalizedString("common_next", comment: ""))
        groupTitleLabel <~ Style.Label.contrastHeadline1
        groupTtpLabel <~ Style.Label.contrastText
        stepTitleLabel <~ Style.Label.contrastTitle1
        stepTipLabel <~ Style.Label.contrastText
    }

    func set(hint: AutoOverlayHint) {
        groupTitleLabel.text = hint.groupTitle
        groupTtpLabel.text = hint.groupTip
        stepTitleLabel.text = hint.stepTitle
        stepTipLabel.text = hint.stepTip
        iconImageView.image = hint.icon
    }

    @IBAction private func closeTap(_ sender: UIButton) {
        closeTapHandler?()
    }
}

struct AutoOverlayHint {
    var groupTitle: String
    var groupTip: String
    var stepTitle: String
    var stepTip: String
    var icon: UIImage?
}
