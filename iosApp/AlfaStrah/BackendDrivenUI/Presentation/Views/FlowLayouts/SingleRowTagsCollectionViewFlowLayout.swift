//
//  SingleRowTagsCollectionViewFlowLayout.swift
//  AlfaStrah
//
//  Created by vit on 02.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class SingleRowTagsCollectionViewFlowLayout: UICollectionViewFlowLayout {
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let superAttributesArray = super.layoutAttributesForElements(in: rect)
		else { return nil }
		
		var newAttributesArray: [UICollectionViewLayoutAttributes] = []
				
		for (index, attributes) in superAttributesArray.enumerated() {
			if index == 0 || superAttributesArray[index - 1].frame.origin.y != attributes.frame.origin.y {
				attributes.frame.origin.x = sectionInset.left
			} else {
				let previousAttributes = superAttributesArray[index - 1]
				let previousFrameRight = previousAttributes.frame.origin.x + previousAttributes.frame.width
				
				attributes.frame.origin.x = previousFrameRight + minimumInteritemSpacing
			}
			
			newAttributesArray.append(attributes)
		}

		return newAttributesArray
	}
}
