//
//  ClinicMetroStationsTagCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 15.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class ClinicMetroStationsTagCollectionViewCell: UICollectionViewCell 
{
	static let id: Reusable<ClinicMetroStationsTagCollectionViewCell> = .fromClass()
	
	// MARK: - Outlets
	private let stackView = createStackView()
	private let pointColorView = UIView()
	private let titleLabel = createTitleLabel()
	private let crossButton = UIButton()
	//var crossImageView = UIImageView()
	
	// MARK: - Variable
	private var metroStation: MetroStation?
	private var tapDeleteMetroStationCallback: ((MetroStation) -> Void)?
	
	// MARK: Lifecycle
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		backgroundView?.isOpaque = true
		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		fatalError("init(coder:) has not been implemented")
	}
}

private extension ClinicMetroStationsTagCollectionViewCell
{
	static func createStackView() -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 5
		
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
		backgroundColor = .Background.backgroundTertiary
		contentView.backgroundColor = .Background.backgroundTertiary
		self.clipsToBounds = true
		self.layer.cornerRadius = 6
		setupStackView()
		setupStationColorView()
		setupTitleLabel()
		setupCrossButton()
	}
	
	func setupStackView()
	{
		contentView.addSubview(stackView)
		stackView.edgesToSuperview(
			excluding: .right,
			insets: .init(
				top: 4,
				left: 8,
				bottom: 4,
				right: 0
			)
		)
	}
	
	func setupStationColorView()
	{
		stackView.addArrangedSubview(createContainerPointColorView())
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
	
	func setupTitleLabel()
	{
		stackView.addArrangedSubview(titleLabel)
	}
	
	func setupCrossButton()
	{
		crossButton.setImage(
			.Icons.cross
				.resized(newWidth: 14)?
				.tintedImage(withColor: .Icons.iconSecondary),
			for: .normal
		)
		
		crossButton.addTarget(self, action: #selector(onCrossTap), for: .touchUpInside)
		
		contentView.addSubview(crossButton)
		crossButton.edgesToSuperview(
			excluding: .left,
			insets: .init(
				top: 4,
				left: 0,
				bottom: 4,
				right: 8
			)
		)
		crossButton.leftToRight(of: stackView, offset: 5)
	}
	
	@objc func onCrossTap()
	{
		guard let metroStation = metroStation
		else { return }
		
		tapDeleteMetroStationCallback?(metroStation)
	}
}

extension ClinicMetroStationsTagCollectionViewCell
{
	func setup(
		metroStation: MetroStation,
		tapDeleteMetroStationCallback: @escaping ((MetroStation) -> Void)
	)
	{
		self.metroStation = metroStation
		self.tapDeleteMetroStationCallback = tapDeleteMetroStationCallback
		titleLabel.text = metroStation.title
		pointColorView.backgroundColor = metroStation.pointColor.color(
			for: traitCollection.userInterfaceStyle
		) ?? .clear
	}
}
