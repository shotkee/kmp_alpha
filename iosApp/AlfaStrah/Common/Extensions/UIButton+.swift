//
//  UIButton+.swift
//  AlfaStrah
//
//  Created by vit on 29.05.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// https://stackoverflow.com/questions/42181550/how-can-i-expand-the-hit-area-of-a-specific-uibutton-in-swift
private var associationKey: UInt8 = 0

extension UIButton {
	var largeTouchAreaEnabled: Bool {
		get {
			return (objc_getAssociatedObject(self, &associationKey) != nil)
		}
		set(newValue) {
			objc_setAssociatedObject(self, &associationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		var touchFrame = bounds
		
		if largeTouchAreaEnabled {
			touchFrame = bounds.insetBy(dx: -20, dy: -20)
		}
		
		return touchFrame.contains(point)
	}
}
