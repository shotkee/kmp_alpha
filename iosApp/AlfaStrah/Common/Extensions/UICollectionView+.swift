//
//  UICollectionView+.swift
//  AlfaStrah
//
//  Created by vit on 09.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension UICollectionView {
	func registerDummyCell() {
		self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "dummy")
	}
	
	func dequeueDummyReusableCell(for indexPath: IndexPath) -> UICollectionViewCell {
		self.dequeueReusableCell(withReuseIdentifier: "dummy", for: indexPath)
	}
}
