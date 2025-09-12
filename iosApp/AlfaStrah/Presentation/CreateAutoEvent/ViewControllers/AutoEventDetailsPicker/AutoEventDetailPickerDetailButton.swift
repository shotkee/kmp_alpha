//
//  AutoEventDetailPickerDetailButton.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 22.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit

class AutoEventDetailPickerDetailButton: UIButton {
	
	init(
		defaultImageName: String,
		selectedImageName: String
	) {
		super.init(frame: .zero)
		
		setImage(
			.init(named: defaultImageName),
			for: .normal
		)
		setImage(
			.init(named: selectedImageName),
			for: .selected
		)
		adjustsImageWhenHighlighted = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		var pixel: [UInt8] = [0, 0, 0, 0]
		let context = CGContext(
			data: &pixel,
			width: 1,
			height: 1,
			bitsPerComponent: 8,
			bytesPerRow: 4,
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
		)
		guard let context
		else {
			return super.hitTest(point, with: event)
		}
		
		context.translateBy(
			x: -point.x,
			y: -point.y
		)
		layer.render(in: context)
		
		let alpha = pixel[3]
		return alpha == 0
			? nil
			: self
	}
}
