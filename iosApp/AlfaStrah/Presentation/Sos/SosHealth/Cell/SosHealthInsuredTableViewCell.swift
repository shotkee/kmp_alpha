//
//  SosHealthInsuredTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 27.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class SosHealthInsuredTableViewCell: UITableViewCell {
    static let id: Reusable<SosHealthInsuredTableViewCell> = .fromClass()
    
    // MARK: - Outlets
    private var titleLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var verticalStackView = UIStackView()
    private var horizontalStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

		fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
		clearStyle()
        setupHorizontalStackView()
        setupVerticalStackView()
        setupTitleLabel()
        setupDescriptionLabel()
        setupRightArrowImageView()
    }
        
	private func setupHorizontalStackView() {
		horizontalStackView.spacing = 9
		horizontalStackView.axis = .horizontal
		horizontalStackView.backgroundColor = .Background.backgroundSecondary
		horizontalStackView.isLayoutMarginsRelativeArrangement = true
		horizontalStackView.layoutMargins = insets(15)

		let container = horizontalStackView.embedded(margins: UIEdgeInsets(top: 15, left: 18, bottom: 15, right: 18), hasShadow: true)
		contentView.addSubview(container)
		container.edgesToSuperview()
	}
    
    private func setupVerticalStackView() {
        let view = UIView()
        view.backgroundColor = .clear
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 3
        horizontalStackView.addArrangedSubview(view)
        view.addSubview(verticalStackView)
        verticalStackView.edgesToSuperview()
    }
    
    private func setupTitleLabel() {
        titleLabel <~ Style.Label.secondaryCaption1
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        verticalStackView.addArrangedSubview(titleLabel)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel <~ Style.Label.primaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        verticalStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupRightArrowImageView() {
        let view = UIView()
        view.backgroundColor = .clear
        view.width(24)
        horizontalStackView.addArrangedSubview(view)
        let iconImageView = UIImageView()
		iconImageView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
        view.addSubview(iconImageView)
        iconImageView.centerXToSuperview()
        iconImageView.centerYToSuperview()
        iconImageView.width(24)
        iconImageView.height(24)
    }
}

extension SosHealthInsuredTableViewCell {
    func configure(
        title: String,
        description: String
    ) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
