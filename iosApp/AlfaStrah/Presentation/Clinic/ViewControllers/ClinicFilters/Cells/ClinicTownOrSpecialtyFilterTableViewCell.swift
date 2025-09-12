//
//  ClinicTownOrSpecialtyFilterTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 14.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class ClinicTownOrSpecialtyFilterTableViewCell: UITableViewCell 
{
	static let id: Reusable<ClinicTownOrSpecialtyFilterTableViewCell> = .fromClass()
	
	// MARK: - Outlets
	private let stackView = createStackView()
	private let titleLabel = createTitleLabel()
	private let checkMarkImageView = createCheckMarkImageView()
	
	// MARK: Lifecycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) 
	{
		super.init(coder: aDecoder)
		
		fatalError("init(coder:) has not been implemented")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool)
	{
		super.setSelected(selected, animated: animated)
		
		checkMarkImageView.isHidden = !selected
	}
}

private extension ClinicTownOrSpecialtyFilterTableViewCell
{
	static func createTitleLabel() -> UILabel
	{
		let label = UILabel()
		label <~ Style.Label.primaryText
		label.numberOfLines = 1
		
		return label
	}
	
	static func createStackView() -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 12
		
		return stackView
	}
	
	static func createCheckMarkImageView() -> UIImageView
	{
		let imageView = UIImageView()
		imageView.image = .Icons.tick
			.resized(newWidth: 24)?
			.tintedImage(withColor: UIColor.Icons.iconAccent)
		
		return imageView
	}
	
	func setupUI()
	{
		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		setupStackView()
		setupTitleLabel()
		setupCheckMarkImageView()
		setupSeparatorView()
	}
	
	func setupStackView()
	{
		contentView.addSubview(stackView)
		stackView.edgesToSuperview(
			insets: .init(
				top: 17,
				left: 18,
				bottom: 17,
				right: 18
			)
		)
	}
	
	func setupTitleLabel()
	{
		stackView.addArrangedSubview(titleLabel)
	}
	
	func setupCheckMarkImageView()
	{
		stackView.addArrangedSubview(checkMarkImageView)
		checkMarkImageView.isHidden = true
	}
	
	func setupSeparatorView()
	{
		let separatoriew = UIView()
		separatoriew.backgroundColor = .Stroke.divider
		separatoriew.height(1)
		contentView.addSubview(separatoriew)
		separatoriew.bottomToSuperview()
		separatoriew.horizontalToSuperview(
			insets: .horizontal(18)
		)
	}
}

extension ClinicTownOrSpecialtyFilterTableViewCell
{
	func setup(
		title: String
	)
	{
		titleLabel.text = title
	}
}
