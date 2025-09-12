//
//  InsuranceView.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 26/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class InsuranceView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!

    private var action: (() -> Void)?

    @IBAction private func insuranceTap(_ sender: Any) {
        action?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
        titleLabel <~ Style.Label.primaryHeadline2
        subtitleLabel <~ Style.Label.secondaryCaption1
    }

    func set(title: String, subtitle: String, action: @escaping () -> Void) {
        self.action = action
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
