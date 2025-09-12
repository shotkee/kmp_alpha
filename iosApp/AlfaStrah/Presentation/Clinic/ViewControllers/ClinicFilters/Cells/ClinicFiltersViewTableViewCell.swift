//
//  ClinicFiltersViewTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 10.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class ClinicFiltersViewTableViewCell: UITableViewCell {
	
	static let id: Reusable<ClinicFiltersViewTableViewCell> = .fromClass()
	
	enum TypeData
	{
		case title(String)
		case view([MetroStation])
	}
	//MARK: - Outlets
	private let titleLabel = createTitleLabel()
	private let arrowImageView = UIImageView()
	private let stackView = createStackView()
	private let pointColorView = UIView()
	
	private var trailingConstraint: NSLayoutConstraint?

	// MARK: Lifecycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) 
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		fatalError("init(coder:) has not been implemented")
	}
}

private extension ClinicFiltersViewTableViewCell
{
	static func createStackView() -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .horizontal
		
		return stackView
	}
	
	static func createTitleLabel() -> UILabel
	{
		let label = UILabel()
		label <~ Style.Label.primaryText
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
		let containerView = UIView()
		let cardView = CardView(contentView: containerView)
		cardView.contentColor = .Background.backgroundSecondary
		
		containerView.addSubview(stackView)
		stackView.verticalToSuperview(insets: .vertical(16))
		stackView.leadingToSuperview(offset: 16)
		
		stackView.addArrangedSubview(titleLabel)
		
		containerView.addSubview(arrowImageView)
		arrowImageView.verticalToSuperview(insets: .vertical(16))
		arrowImageView.trailingToSuperview(offset: 16)
		arrowImageView.leadingToTrailing(of: stackView, offset: 8, relation: .equalOrGreater)
		arrowImageView.image = .Icons.arrow.resized(newWidth: 20)?.tintedImage(withColor: .Icons.iconSecondary)
		
		contentView.addSubview(cardView)
		cardView.edgesToSuperview(
			excluding: .trailing,
			insets: .init(
				top: 15,
				left: 18,
				bottom: 0,
				right: 0
			)
		)
		trailingConstraint = cardView.rightToSuperview(offset: -18)
	}
	
	func setupTitleLabel(title: String)
	{
		stackView.addArrangedSubview(titleLabel)
		titleLabel.text = title
	}
	
	func setupMetroStationView(metroStations: [MetroStation])
	{
		if metroStations.isEmpty
		{
			setupTitleLabel(
				title: NSLocalizedString("clinic_filter_city_metro_station_title", comment: "")
			)
		}
		else if metroStations.count == 1,
				let metroStation = metroStations.first
		{
			setupStationStackView(metroStation: metroStation)
		}
		else
		{
			let localized = NSLocalizedString(
				"count_metro_stations",
				comment: ""
			)
			
			let specialitiesString = String(
				format: localized,
				locale: .init(identifier: "ru"),
				metroStations.count
			)
			
			setupTitleLabel(
				title: specialitiesString
			)
		}
	}
	
	func setupStationStackView(metroStation: MetroStation)
	{
		stackView.addArrangedSubview(createContainerPointColorView())
		pointColorView.backgroundColor = metroStation.pointColor.color(
			for: traitCollection.userInterfaceStyle
		) ?? .clear
		stackView.addArrangedSubview(titleLabel)
		titleLabel.text = metroStation.title
	}
	
	func createContainerPointColorView() -> UIView
	{
		let containerView = UIView()
		containerView.backgroundColor = .clear
		
		let view = UIView()
		view.backgroundColor = .clear
		view.size(
			.init(width: 12, height: 12)
		)
		
		pointColorView.clipsToBounds = true
		pointColorView.layer.cornerRadius = 4
		
		view.addSubview(pointColorView)
		pointColorView.edgesToSuperview(
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

extension ClinicFiltersViewTableViewCell
{
	func setup(
		typeData: TypeData,
		hasMetroStationList: Bool
	)
	{
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		switch typeData
		{
			case .title(let title):
				setupTitleLabel(title: title)
			
			case .view(let metroStations):
				setupMetroStationView(metroStations: metroStations)
		}
		
		trailingConstraint?.constant = hasMetroStationList ? -6 : -18
	}
}
