//
//  VzrOnOffDayPackageView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/16/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class DayPackageView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!

    private var action: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        titleLabel <~ Style.Label.secondaryText
        priceLabel <~ Style.Label.primaryHeadline3
    }

    @IBAction private func buttonTap(_ sender: UIButton) {
        action?()
    }

    func configure(title: String, price: Double, currency: String, action: @escaping () -> Void) {
        titleLabel.text = title
        priceLabel.text = AppLocale.price(from: NSNumber(value: price), currencyCode: currency)
        self.action = action
    }
}
