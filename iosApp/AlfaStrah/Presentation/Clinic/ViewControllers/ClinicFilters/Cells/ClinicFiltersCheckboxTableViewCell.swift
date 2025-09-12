//
//  ClinicFiltersCheckboxTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 10.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class ClinicFiltersCheckboxTableViewCell: UITableViewCell
{
	static let id: Reusable<ClinicFiltersCheckboxTableViewCell> = .fromClass()
	
	enum TypeData
	{
		case usual(String)
		case metro(MetroStation)
	}
	
	// MARK: - Outlets
	
	private let checkbox = CommonCheckboxButton(appearance: .checkbox)
	private let stackView = createStackView()
	private let titleLabel = createTitleLabel()
	private let countClinicsLabel = createCountClinicsLabel()
	private let overlaySelectButton = UIButton()
	
	var tapSelectedCallback: (() -> Void)?
	

	// MARK: Lifecycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) 
	{
		super.init(coder: aDecoder)
		
		fatalError("init(coder:) has not been implemented")
	}
}

private extension ClinicFiltersCheckboxTableViewCell
{
	static func createStackView() -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 4
		
		return stackView
	}
	
	static func createTitleLabel() -> UILabel
	{
		let label = UILabel()
		label <~ Style.Label.primaryText
		label.numberOfLines = 1
		
		return label
	}
	
	static func createCountClinicsLabel() -> UILabel
	{
		let label = UILabel()
		label <~ Style.Label.secondaryText
		label.numberOfLines = 1
		
		return label
	}
	
	func setupUI()
	{
		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		setupCheckbox()
		setupStackView()
		setupOverlaySelectButton()
	}
	
	func setupOverlaySelectButton()
	{
		contentView.addSubview(overlaySelectButton)
		overlaySelectButton.backgroundColor = .clear
		overlaySelectButton.edgesToSuperview()
		overlaySelectButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
	}
	
	@objc private func onTap()
	{
		tapSelectedCallback?()
		checkbox.isSelected = !checkbox.isSelected
	}
	
	func setupCheckbox()
	{
		contentView.addSubview(checkbox)
		checkbox.centerYToSuperview()
		checkbox.width(20)
		checkbox.heightToWidth(of: checkbox)
		checkbox.leadingToSuperview(offset: 18)
		checkbox.isUserInteractionEnabled = false
	}
	
	func setupStackView()
	{
		contentView.addSubview(stackView)
		stackView.verticalToSuperview(
			insets: .vertical(16)
		)
		stackView.trailingToSuperview(offset: 18)
		stackView.leadingToTrailing(of: checkbox, offset: 8)
	}
	
	func setupTitleLabel(title: String)
	{
		titleLabel.text = title
		stackView.addArrangedSubview(titleLabel)
	}
	
	func setupStationView(metroStation: MetroStation)
	{
		let color = metroStation.pointColor.color(for: traitCollection.userInterfaceStyle) ?? .clear
		let colorStackView = UIStackView()
		colorStackView.axis = .horizontal
		colorStackView.addArrangedSubview(
			createStationColorView(color: color)
		)
		
		stackView.addArrangedSubview(colorStackView)
		titleLabel.text = metroStation.title
		titleLabel.setContentHuggingPriority(.required, for: .horizontal)
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(countClinicsLabel)
		if let clinicCount = metroStation.clinicCount
		{
			let localized = NSLocalizedString(
				"count_clinic",
				comment: ""
			)
			
			let clinicString = String(
				format: localized,
				locale: .init(identifier: "ru"),
				clinicCount
			)
			
			countClinicsLabel.text = "(\(clinicString))"
		}
		else
		{
			countClinicsLabel.text = NSLocalizedString(
				"clinic_filter_not_clinics",
				comment: ""
			)
		}
		countClinicsLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
	}
	
	func createStationColorView(color: UIColor) -> UIView
	{
		let containerView = UIView()
		containerView.backgroundColor = .clear
		
		let view = UIView()
		view.backgroundColor = .clear
		view.size(
			.init(width: 12, height: 12)
		)
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = color
		backgroundView.clipsToBounds = true
		backgroundView.layer.cornerRadius = 4
		
		view.addSubview(backgroundView)
		backgroundView.edgesToSuperview(
			insets: .init(
				top: 2,
				left: 2,
				bottom: 2,
				right: 2
			)
		)
		
		containerView.addSubview(view)
		view.edgesToSuperview(
			insets: .init(
				top: 4,
				left: 0,
				bottom: 4,
				right: 0
			)
		)
		
		return containerView
	}
}

extension ClinicFiltersCheckboxTableViewCell
{
	func setup(
		typeData: TypeData,
		isSelected: Bool
	)
	{
		stackView.subviews.forEach { $0.removeFromSuperview() }
		
		switch typeData
		{
			case .usual(let title):
				setupTitleLabel(title: title)
			
			case .metro(let metroStation):
				setupStationView(metroStation: metroStation)
		}
		
		checkbox.isSelected = isSelected
	}
}
