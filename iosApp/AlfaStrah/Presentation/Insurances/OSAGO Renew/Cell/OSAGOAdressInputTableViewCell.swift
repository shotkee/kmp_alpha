//
//  OSAGOAdressInputTableViewCell.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 12.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class OSAGOAdressInputTableViewCell: UITableViewCell {
    static let id: Reusable<OSAGOAdressInputTableViewCell> = .fromClass()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    private func setupUI() {
        guard let label = textLabel else { return }

        label <~ Style.Label.primaryText
    }

    func set(value: String) {
        textLabel?.text = value
    }
}
