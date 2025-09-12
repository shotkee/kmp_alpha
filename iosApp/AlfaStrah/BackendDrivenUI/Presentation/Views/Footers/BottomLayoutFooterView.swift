//
//  BottomLayoutFooterView.swift
//  AlfaStrah
//
//  Created by vit on 10.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BottomLayoutFooterView: FooterView<BottomLayoutFooterDTO> {		
		required init(
			block: BottomLayoutFooterDTO,
			horizontalInset: CGFloat = 0,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			if let layout = block.layout {
				let bottomView = ViewBuilder.constructWidgetView(
					for: layout,
					horizontalLayoutOneSideContentInset: self.horizontalInset,
					handleEvent: self.handleEvent
				)
				
				addSubview(bottomView)
				bottomView.edgesToSuperview()
			}
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
		}
	}
}
