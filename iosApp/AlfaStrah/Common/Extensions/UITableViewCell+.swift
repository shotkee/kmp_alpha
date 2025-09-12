//
//  UITableViewCell+.swift
//  AlfaStrah
//
//  Created by vit on 28.02.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension UITableViewCell {
	func clearStyle() {
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
	}
}
