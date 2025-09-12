//
//  ClinicMetroCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 08.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class ClinicMetroCollectionViewCell: UICollectionViewCell 
{
	static let id: Reusable<ClinicMetroCollectionViewCell> = .fromClass()
	
	// MARK: - Outlets
	private let stackView = createStackView()
	private let imageContainerView = createImageContainerView()
	private let metroImageView = UIImageView()
	private let titleLabel = createTitleLabel()
	
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

extension ClinicMetroCollectionViewCell
{
	func setup(metro: ClinicMetro)
	{
		titleLabel.text = metro.title
		metroImageView.image = .Icons.metroBlue
			.resized(newWidth: 16)?
			.tintedImage(
				withColor: metro.color.color(
					for: traitCollection.userInterfaceStyle
				) ?? UIColor.blue
			)
	}
}

private extension ClinicMetroCollectionViewCell
{
	static func createStackView() -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 4
		
		return stackView
	}
	
	static func createImageContainerView() -> UIView
	{
		let view = UIView()
		return view
	}
	
	static func createTitleLabel() -> UILabel
	{
		let label = UILabel()
		label <~ Style.Label.primaryText
		label.numberOfLines = 1
		label.text = "Удельная"
		
		return label
	}
	
	func setupUI()
	{
		imageContainerView.addSubview(metroImageView)
		metroImageView.edgesToSuperview(
			insets: .init(
				top: 2,
				left: 0,
				bottom: 2,
				right: 0
			)
		)
		contentView.addSubview(stackView)
		stackView.edgesToSuperview()
		stackView.addArrangedSubview(imageContainerView)
		stackView.addArrangedSubview(titleLabel)
	}
}
