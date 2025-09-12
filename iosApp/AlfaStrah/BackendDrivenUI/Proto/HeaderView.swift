//
//  HeaderView.swift
//  AlfaStrah
//
//  Created by vit on 28.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class HeaderView<T: HeaderDTO>: UIView, HeaderInitializable {
		let block: T
		let horizontalInset: CGFloat
		let handleEvent: (EventsDTO) -> Void
		
		required init(
			block: T,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.block = block
			self.horizontalInset = horizontalInset
			self.handleEvent = handleEvent
			
			super.init(frame: .zero)
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
}
