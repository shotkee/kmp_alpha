//
//  InsuranceTypeView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 31/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class InsuranceTypeView: UIView {
    private var iconImageView = UIImageView()
    private var titleLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    func set(title: String, image: UIImage?) {
        iconImageView.image = image
        titleLabel.text = title
        addSubview(iconImageView)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 3),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor, constant: 9),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            titleLabel.heightAnchor.constraint(equalToConstant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func setupStyle() {
        titleLabel <~ Style.Label.primaryCaption1
    }
}
