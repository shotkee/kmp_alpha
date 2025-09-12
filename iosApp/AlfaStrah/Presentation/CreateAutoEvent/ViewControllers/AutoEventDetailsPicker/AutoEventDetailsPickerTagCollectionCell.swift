//
//  AutoEventDetailsPickerTagCollectionCell.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 21.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class AutoEventDetailsPickerTagCollectionCell: UICollectionViewCell {
	
	static let id: Reusable<AutoEventDetailsPickerTagCollectionCell> = .fromClass()
	
	private let titleLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		clearStyle()
		
		// content view
		contentView.backgroundColor = .Background.backgroundAccent
		contentView.layer.cornerRadius = 6
		contentView.clipsToBounds = true
		contentView.height(24)
		
		// title
		titleLabel <~ Style.Label.contrastText
		titleLabel.numberOfLines = 1

		contentView.addSubview(titleLabel)
		titleLabel.leadingToSuperview(offset: 8)
		titleLabel.centerYToSuperview()
		
		// delete button
		let deleteButton = UIButton(type: .system)
		deleteButton.setImage(
			.Icons.cross,
			for: .normal
		)
		deleteButton.tintColor = .Icons.iconContrast
		contentView.addSubview(deleteButton)
		deleteButton.leadingToTrailing(
			of: titleLabel,
			offset: 4
		)
		deleteButton.trailingToSuperview(offset: 8)
		deleteButton.centerYToSuperview()
		deleteButton.width(14)
		deleteButton.aspectRatio(1)
	}
	
	func configure(title: String?) {
		titleLabel.text = title
	}
}
