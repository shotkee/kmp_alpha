//
//  AboutInsuranceEntryTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 13.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class AboutInsuranceEntryTableViewCell: UITableViewCell {
    static let id: Reusable<AboutInsuranceEntryTableViewCell> = .fromClass()
    
    private var descriptionStackView = UIStackView()
    private var titleLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var stackView = UIStackView()

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
        setupDescriptionStackView()
        setupTitleLabel()
        setupDescriptionLabel()
        setupStackView()
    }
    
    private func setupDescriptionStackView() {
        descriptionStackView.axis = .vertical
        descriptionStackView.spacing = 9
        descriptionStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionStackView)
        NSLayoutConstraint.activate([
            descriptionStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 21),
            descriptionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            descriptionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        descriptionStackView.addArrangedSubview(titleLabel)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionStackView.addArrangedSubview(descriptionLabel)
    }
	
    private func setupStackView() {
        stackView.axis = .vertical
		stackView.backgroundColor = .Background.backgroundSecondary

		let cardView = stackView.embedded(
			margins: UIEdgeInsets(top: 24, left: 18, bottom: 7, right: 24),
			hasShadow: true,
			cornerRadius: 12
		)
		
		contentView.addSubview(cardView)
		
		cardView.topToBottom(of: descriptionStackView)
		cardView.horizontalToSuperview()
    }
}

extension AboutInsuranceEntryTableViewCell {
    func configure(
        insuranceReportVZRDetailed: InsuranceReportVZRDetailed,
		textColor: UIColor
    ) {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        titleLabel.text = insuranceReportVZRDetailed.status
		
		titleLabel.textColor = textColor

        descriptionLabel.isHidden = insuranceReportVZRDetailed.description == nil
        descriptionLabel.text = insuranceReportVZRDetailed.description
        for index in 0..<insuranceReportVZRDetailed.detailedContent.count {
            stackView.addArrangedSubview(
                createInfoView(
                    title: insuranceReportVZRDetailed.detailedContent[index].title,
                    description: insuranceReportVZRDetailed.detailedContent[index].value,
                    isLastItem: index == insuranceReportVZRDetailed.detailedContent.count - 1
                )
            )
        }
    }
    
    
    private func createInfoView(
        title: String,
        description: String,
        isLastItem: Bool
    ) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 9),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
        
        let titleLabel = UILabel()
        titleLabel <~ Style.Label.secondaryCaption1
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 1
        titleLabel.text = title
        stackView.addArrangedSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel <~ Style.Label.primaryText
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = description
        stackView.addArrangedSubview(descriptionLabel)
        
        let separatorView = UIView()
        separatorView.backgroundColor = isLastItem
            ? .clear
			: .Stroke.divider
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 9),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return view
    }
}
