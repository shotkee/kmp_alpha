//
//  HeaderSelector+.swift
//  AlfaStrah
//
//  Created by vit on 19.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import SDWebImage

extension BDUI.HeaderSelector {		
	func buildHeader<T: UIView & BDUI.HeaderInitializable>(
		_ block: T.H,
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
