//
//  SosHealthTypeConnectionTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 27.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class SosHealthTypeConnectionTableViewCell: UITableViewCell {
    static let id: Reusable<SosHealthTypeConnectionTableViewCell> = .fromClass()
    
    enum TypeCell {
        case call
        case onlineCall
    }
    
    // MARK: - Outlets
    private var titleLabel = UILabel()
    private var horizontalStackView = UIStackView()
    private var iconImageView = UIImageView()

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
        view.addSubview(iconImageView)
        iconImageView.centerXToSuperview()
        iconImageView.centerYToSuperview()
        iconImageView.width(24)
        iconImageView.height(24)
    }
}

extension SosHealthTypeConnectionTableViewCell {
    func configure(
        type: TypeCell
    ) {
        switch type {
            case .call:
				iconImageView.image = UIImage(named: "call")?.tintedImage(withColor: .Icons.iconAccent)
                titleLabel.text = NSLocalizedString("sos_health_call_title", comment: "")
            case .onlineCall:
				iconImageView.image = UIImage(named: "icon-phone-white")?.tintedImage(withColor: .Icons.iconAccent)
                titleLabel.text = NSLocalizedString("sos_health_online_call_title", comment: "")
        }
    }
}
