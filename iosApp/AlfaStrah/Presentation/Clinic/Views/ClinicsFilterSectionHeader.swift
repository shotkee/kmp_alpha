//
//  ClinicsFilterSectionHeader.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 23.05.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class ClinicsFilterSectionHeader: UITableViewHeaderFooterView
{
    private let titleLabel = UILabel()

    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)

        setup()
    }

    private func setup()
    {
        backgroundColor = .clear

        titleLabel.font = Style.Font.text
        titleLabel.textColor = Style.Color.Palette.darkGray

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: 16
            ),
            titleLabel.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: 24
            )
        ])
    }

    func set(title: String)
    {
        titleLabel.text = title
    }
}
