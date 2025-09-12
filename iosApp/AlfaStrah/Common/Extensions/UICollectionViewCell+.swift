//
//  UICollectionViewCell+.swift
//  AlfaStrah
//
//  Created by vit on 05.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension UICollectionViewCell {
	func clearStyle() {
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
	}
}
