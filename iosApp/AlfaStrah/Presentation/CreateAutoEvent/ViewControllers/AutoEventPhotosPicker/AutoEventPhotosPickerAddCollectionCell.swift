//
//  AutoEventPhotosPickerAddCollectionCell.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 13.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy

class AutoEventPhotosPickerAddCollectionCell: UICollectionViewCell {
	
	static let id: Reusable<AutoEventPhotosPickerAddCollectionCell> = .fromClass()
	
	private let plusIconImageView = createPlusIconImageView()
	
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
		contentView.backgroundColor = .Background.backgroundTertiary
		contentView.layer.cornerRadius = 10
		contentView.clipsToBounds = true
		
		// plus icon
		contentView.addSubview(plusIconImageView)
		plusIconImageView.centerInSuperview()
	}
	
	private static func createPlusIconImageView() -> UIImageView {
		return UIImageView(image: .Icons.plus)
	}
	
	func setState(isActive: Bool) {
		plusIconImageView.tintColor = isActive
			? .Icons.iconAccent
			: .Icons.iconSecondary
	}
}
