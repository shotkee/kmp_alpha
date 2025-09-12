//
//  AddressSuggestionCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 28.01.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class AddressSuggestionCell: UITableViewCell {
    static let id: Reusable<AddressSuggestionCell> = .fromClass()

    private let streetLabel = UILabel()
    private let cityLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    private func setupUI() {
        streetLabel.translatesAutoresizingMaskIntoConstraints = false
        streetLabel.setContentHuggingPriority(.init(rawValue: 251), for: .vertical)
        contentView.addSubview(streetLabel)
        streetLabel <~ Style.Label.primaryText
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cityLabel)
        cityLabel <~ Style.Label.secondaryCaption1
        NSLayoutConstraint.activate([
            streetLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            streetLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            streetLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            cityLabel.leadingAnchor.constraint(equalTo: streetLabel.leadingAnchor),
            cityLabel.topAnchor.constraint(equalTo: streetLabel.bottomAnchor, constant: 5),
            cityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            cityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func set(street: String, city: String) {
        streetLabel.text = street
        cityLabel.text = city
    }
}
