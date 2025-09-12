//
//  BuyInsuranceView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 08/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class BuyInsuranceView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    private var action: (() -> Void)?

    @IBAction private func insuranceTap(_ sender: Any) {
        action?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
        titleLabel <~ Style.Label.primaryHeadline1
    }

    func set(title: String, action: @escaping () -> Void) {
        titleLabel.text = title
        self.action = action
    }
}
