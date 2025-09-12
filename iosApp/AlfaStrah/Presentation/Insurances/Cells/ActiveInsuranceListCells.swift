//
//  ActiveInsuranceListCells.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 29.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class ActiveInsuranceCell: UITableViewCell {
    static var id: Reusable<ActiveInsuranceCell> = .fromClass()

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var hintLabel: UILabel!
    @IBOutlet private var warningLabel: UILabel!
	@IBOutlet private var arrowImageView: UIImageView!

    func set(title: String?, hint: String?, warning: String?) {
        titleLabel.text = title
        hintLabel.text = hint
        warningLabel.text = warning
		updateTheme()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let image = arrowImageView.image
		
		arrowImageView.image = image?.tintedImage(withColor: .Icons.iconSecondary)
	}
}

class CardInsuranceCell: UITableViewCell {
    static let id: Reusable<CardInsuranceCell> = .fromClass()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let stackView = UIStackView()
    private let iconView = UIImageView()
    private let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        setupContainerView()
        setupIconView()
        setupStackView()
        setupTitleLabel()
        setupSubtitleLabel()
        setupDescriptionLabel()
    }
    
    private func setupContainerView() {
        contentView.addSubview(containerView.embedded(hasShadow: true, isUserInteractionEnabled: false))
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.backgroundColor = .Background.backgroundSecondary
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: containerView,
                in: contentView,
                margins: UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18)
            )
        )
    }
    
    private func setupIconView() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
		iconView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
        containerView.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            iconView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor)
        ])
    }
        
    private func setupStackView() {
        containerView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.layoutMargins = .zero
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -18),
            stackView.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -8)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel.numberOfLines = 0
        titleLabel <~ Style.Label.primaryHeadline3
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setupSubtitleLabel() {
        subtitleLabel.numberOfLines = 0
        subtitleLabel <~ Style.Label.primaryCaption1
        
        stackView.addArrangedSubview(subtitleLabel)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.numberOfLines = 0
        descriptionLabel <~ Style.Label.secondaryCaption1
        
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    func set(
        title: String,
        subtitle: String,
        description: String
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        descriptionLabel.text = description
    }
}
