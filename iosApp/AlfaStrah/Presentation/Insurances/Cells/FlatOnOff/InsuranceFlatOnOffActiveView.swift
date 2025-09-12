//
//  InsuranceFlatOnOffActiveView.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 02.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class InsuranceFlatOnOffActiveView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var periodLabel: UILabel!
    @IBOutlet private var balanceLabel: UILabel!
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
        titleLabel.text = NSLocalizedString("flat_on_off_active_title", comment: "")
        titleLabel <~ Style.Label.primaryText
        periodLabel <~ Style.Label.primaryHeadline1
        purchaseButton <~ Style.Button.redLabelButton
        purchaseButton.setTitle(NSLocalizedString("flat_on_off_purchase_button_title", comment: ""), for: .normal)
        activateButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        activateButton.setTitle(NSLocalizedString("flat_on_off_activate_button_title", comment: ""), for: .normal)
    }

    func configure(
        start: Date,
        finish: Date,
        balance: Int,
        purchaseAction: @escaping () -> Void,
        activateAction: @escaping () -> Void
    ) {
        let from = AppLocale.shortDateString(start)
        let to = AppLocale.shortDateString(finish)
        let format = NSLocalizedString("flat_on_off_active_period", comment: "")
        periodLabel.text = String.localizedStringWithFormat(format, from, to)

        let balanceString = (NSLocalizedString("flat_on_off_active_balance", comment: "") <~ Style.TextAttributes.grayInfoText).mutable
        let balanceValue = String(describing: balance) <~ Style.TextAttributes.daysBalanceBoldText
        balanceString.replace("{balance}", with: balanceValue)
        balanceLabel.attributedText = balanceString

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
