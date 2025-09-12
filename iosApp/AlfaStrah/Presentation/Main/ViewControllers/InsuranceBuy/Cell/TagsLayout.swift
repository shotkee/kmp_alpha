//
//  TagsLayout.swift
//  AlfaStrah
//
//  Created by Makson on 26.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class TagsLayout: UICollectionViewFlowLayout {
    required override init() {
        super.init()
        
        common()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        common()
    }
    
    private func common() {
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        minimumLineSpacing = 6
        minimumInteritemSpacing = 6
    }
    
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attibutes = super.layoutAttributesForElements(in: rect)
        else {
            return []
        }
        
        var x: CGFloat = sectionInset.left
        var y: CGFloat = -1.0
        
        for attibute in attibutes {
            if attibute.representedElementCategory != .cell { continue }
            
            if attibute.frame.origin.y >= y {
                x = sectionInset.left
            }
            
            attibute.frame.origin.x = x
            x += attibute.frame.width + minimumInteritemSpacing
            y = attibute.frame.maxY
        }
        
        return attibutes
    }
}
