//
//  InsuranceFlatOnOffInactiveView.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 02.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class InsuranceFlatOnOffInactiveView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var purchaseButton: UIButton!
    @IBOutlet private var activateButton: RoundEdgeButton!

    private var purchaseAction: (() -> Void)?
    private var activateAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        titleLabel <~ Style.Label.primaryHeadline1
        subtitleLabel <~ Style.Label.primaryText
        purchaseButton <~ Style.Button.redLabelButton
        purchaseButton.setTitle(NSLocalizedString("flat_on_off_purchase_button_title", comment: ""), for: .normal)
        activateButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        activateButton.setTitle(NSLocalizedString("flat_on_off_activate_button_title", comment: ""), for: .normal)
    }

    func configure(balance: Int, purchaseAction: @escaping () -> Void, activateAction: @escaping () -> Void) {
        let format = NSLocalizedString("flat_on_off_inactive_title", comment: "")
        titleLabel.text = String.localizedStringWithFormat(format, balance)
        subtitleLabel.text = NSLocalizedString("flat_on_off_inactive_subtitle", comment: "")

        self.purchaseAction = purchaseAction
        self.activateAction = activateAction
    }

    @IBAction private func purchase() {
        purchaseAction?()
    }

    @IBAction private func activate() {
        activateAction?()
    }
}
