//
//  ButtonWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 14.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import SDWebImage

extension BDUI {
	class ButtonWidgetView: WidgetView<ButtonWidgetDTO> {
		private let button = RoundEdgeButton()
		
		required override init(
			block: ButtonWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			addSubview(button)
			
			button.setTitle(block.themedTitle?.text, for: .normal)
			button.height(48)
			
			button.addTarget(self, action: #selector(viewTap), for: .touchUpInside)
			
			button.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
			
			button.titleLabel?.adjustsFontSizeToFitWidth = true
			
			updateTheme()
		}
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			button <~ Style.RoundedButton.RoundedParameterizedButton(
				textColor: block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle),
				backgroundColor: block.themedBackgroundColor?.color(for: currentUserInterfaceStyle),
				borderColor: block.themedBorderColor?.color(for: currentUserInterfaceStyle)
			)
			
			SDWebImageManager.shared.loadImage(
				with: block.leftThemedIcon?.url(for: currentUserInterfaceStyle),
				options: .highPriority,
				progress: nil,
				completed: { image, _, _, _, _, _ in
					self.button.setImage(image?.resized(newWidth: 20), for: .normal)
				}
			)
		}
	}
}
