//
//  CheckboxButtonComponentView.swift
//  AlfaStrah
//
//  Created by vit on 21.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class CheckboxButtonComponentView: UIButton {
		init() {
			super.init(frame: .zero)
			
			setup()
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
			
			fatalError("init(coder:) has not been implemented")
		}
		
		override var intrinsicContentSize: CGSize {
			let side: CGFloat = 24
			return .init(
				width: side,
				height: side
			)
		}
		
		override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
			let touchFrame = bounds.insetBy(dx: -20, dy: -20)
			
			return touchFrame.contains(point)
		}
		
		// MARK: - Setup
		private func setup() {
			layer.cornerRadius = 6
			layer.masksToBounds = true
		}
	}
}
