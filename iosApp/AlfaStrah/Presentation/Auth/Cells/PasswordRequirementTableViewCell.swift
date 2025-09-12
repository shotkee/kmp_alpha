//
//  PasswordRequirementTableViewCell.swift
//  AlfaStrah
//
//  Created by vit on 13.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class PasswordRequirementTableViewCell: UITableViewCell {
    static let id: Reusable<PasswordRequirementTableViewCell> = .fromClass()

    private let statusImageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let containerView = UIView()

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.contentMode = .scaleAspectFit
        containerView.addSubview(statusImageView)

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.numberOfLines = 0
        containerView.addSubview(descriptionLabel)
        
		let offset = (descriptionLabel.font.ascender + descriptionLabel.font.descender) * 0.5
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: containerView, in: contentView) + [
            statusImageView.heightAnchor.constraint(equalTo: statusImageView.widthAnchor),
            statusImageView.heightAnchor.constraint(equalToConstant: 20),
            statusImageView.centerYAnchor.constraint(equalTo: descriptionLabel.firstBaselineAnchor, constant: -offset),
            statusImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            descriptionLabel.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 6),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

    func configure(
        isSatisfied: Bool,
        text: String
    ) {
        statusImageView.image = isSatisfied
			? .Icons.tickInCircle.tintedImage(withColor: .Pallete.accentGreen)
			: .Icons.deleteSmall.tintedImage(withColor: .Icons.iconTertiary)
		
        descriptionLabel.text = text
        containerView.sizeToFit()
    }
}
