//
//  InsuranceEntryTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 13.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class InsuranceEntryTableViewCell: UITableViewCell {
    static let id: Reusable<InsuranceEntryTableViewCell> = .fromClass()
    
    // MARK: - Outlets
//    private var shadowView = ShadowView()
    private var containerView = UIView()
    private var stackView = UIStackView()
    private var dateStackView = UIStackView()
    private var dateLabel = UILabel()
    private var pointView = UIView()
    private var numberNotificationLabel = UILabel()
    private var nameLabel = UILabel()
    private var typeEntryLabel = UILabel()
    private var arrowRightImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
}

private extension InsuranceEntryTableViewCell {
    func setupUI() {
		clearStyle()
        setupContainerView()
        setupStackView()
        setupDateStackView()
        setupNameLabel()
        setupTypeEntryLabel()
        setupArrowRightImageView()
        setupDateLabel()
        setupPointView()
        setupNumberNotificationLabel()
    }

    func setupContainerView() {
		containerView.backgroundColor = .Background.backgroundSecondary

		let cardView = containerView.embedded(
			margins: UIEdgeInsets(top: 7, left: 18, bottom: 7, right: 18),
			hasShadow: true,
			cornerRadius: 10
		)
		contentView.addSubview(cardView)
		
		NSLayoutConstraint.activate(
			NSLayoutConstraint.fill(view: cardView, in: contentView)
		)
    }
    
    func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 6
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        containerView.addSubview(stackView)

		stackView.edgesToSuperview(excluding: .trailing)
    }
    
    func setupDateStackView() {
        let view = UIView()
        view.backgroundColor = .clear
        stackView.addArrangedSubview(view)
        dateStackView.axis = .horizontal
        dateStackView.spacing = 6
        dateStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateStackView)
        NSLayoutConstraint.activate([
            dateStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateStackView.topAnchor.constraint(equalTo: view.topAnchor),
            dateStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: 0),
            dateStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dateStackView.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    func setupNameLabel() {
        nameLabel <~ Style.Label.primaryHeadline1
        stackView.addArrangedSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func setupTypeEntryLabel() {
        typeEntryLabel <~ Style.Label.primarySubhead
        stackView.addArrangedSubview(typeEntryLabel)
        NSLayoutConstraint.activate([
            typeEntryLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    func setupArrowRightImageView() {
		arrowRightImageView.image = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
        arrowRightImageView.contentMode = .scaleAspectFill
        arrowRightImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(arrowRightImageView)
        
		arrowRightImageView.centerYToSuperview()
		arrowRightImageView.trailingToSuperview(offset: 18)
		arrowRightImageView.leadingToTrailing(of: stackView, offset: 8)
		arrowRightImageView.width(24)
		arrowRightImageView.heightToWidth(of: arrowRightImageView)
    }
    
    func setupDateLabel() {
        dateLabel <~ Style.Label.secondarySubhead
        dateLabel.textAlignment = .left
        dateStackView.addArrangedSubview(dateLabel)
    }
    
    func setupPointView() {
        pointView.backgroundColor = .clear
        dateStackView.addArrangedSubview(pointView)
        NSLayoutConstraint.activate([
            pointView.widthAnchor.constraint(equalToConstant: 3)
        ])
        
        let pointLabel = UILabel()
        pointLabel <~ Style.Label.secondarySubhead
        pointLabel.text = "·"
        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        pointView.addSubview(pointLabel)
        
        NSLayoutConstraint.activate([
            pointLabel.centerXAnchor.constraint(equalTo: pointView.centerXAnchor),
            pointLabel.centerYAnchor.constraint(equalTo: pointView.centerYAnchor)
        ])
    }
    
    func setupNumberNotificationLabel() {
        numberNotificationLabel <~ Style.Label.secondarySubhead
        numberNotificationLabel.textAlignment = .left
        dateStackView.addArrangedSubview(numberNotificationLabel)
    }
}

extension InsuranceEntryTableViewCell {
    func configure(
        insuranceReportVZR: InsuranceReportVZR,
		textColor: UIColor
    ) {
        dateLabel.text = insuranceReportVZR.dateString
        numberNotificationLabel.text = insuranceReportVZR.numberNofication
        nameLabel.text = insuranceReportVZR.title
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.adjustsFontSizeToFitWidth = false
        typeEntryLabel.text = insuranceReportVZR.status

		typeEntryLabel.textColor = textColor
    }
}
