//
//  VzrOnOffPurchaseHistoryCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/17/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class VzrOnOffPurchaseHistoryCell: UITableViewCell {
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!

    static let id: Reusable<VzrOnOffPurchaseHistoryCell> = .fromNib()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        dateLabel <~ Style.Label.primaryHeadline3
        titleLabel <~ Style.Label.primaryText
        priceLabel <~ Style.Label.accentHeadline3
    }

    func configure(date: Date, title: String, price: Double, currencyCode: String) {
        dateLabel.text = AppLocale.shortDateString(date)
        titleLabel.text = title
        priceLabel.text = AppLocale.price(from: NSNumber(value: price), currencyCode: currencyCode)
    }
}
