//
//  QAHeader.swift
//  AlfaStrah
//
//  Created by mac on 27.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class QAHeader: UIView {
    @IBOutlet private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        titleLabel <~ Style.Label.primaryHeadline1
    }

    func set(title: String) {
        titleLabel.text = title
    }
}
