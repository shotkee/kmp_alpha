//
//  FooterSelector+.swift
//  AlfaStrah
//
//  Created by vit on 10.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

extension BDUI.FooterSelector {	
	func buildFooter<T: UIView & BDUI.FooterInitializable>(
		_ block: T.F,
		layoutContentInset: CGFloat = 0,
		handleEvent: @escaping (BDUI.EventSelector) -> Void,
		for _: T.Type
	) -> UIView {
		let blockView = T.init(
			block: block,
			horizontalInset: layoutContentInset,
			handleEvent: handleEvent
		)
		
		return blockView
	}
}
