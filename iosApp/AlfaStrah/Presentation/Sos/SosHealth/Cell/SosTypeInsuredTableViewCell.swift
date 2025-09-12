//
//  SosTypeInsuredTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 27.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class SosTypeInsuredTableViewCell: UITableViewCell {
    static let id: Reusable<SosTypeInsuredTableViewCell> = .fromClass()
    
    // MARK: - Outlets
    private var titleLabel = UILabel()
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
        setupTitleLabel()
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
    
    private func setupTitleLabel() {
        titleLabel <~ Style.Label.primaryText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.height(22)
        horizontalStackView.addArrangedSubview(titleLabel)
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
        iconImageView.height(22)
    }
}

extension SosTypeInsuredTableViewCell {
    func configure(
        title: String
    ) {
        titleLabel.text = title
    }
}
