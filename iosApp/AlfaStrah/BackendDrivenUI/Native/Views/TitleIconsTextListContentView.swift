//
//  TitleIconsTextListContentView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 23.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

extension BDUI {
	class TitleIconsTextListContentView: UIView {
		private let block: TitleIconsTextListItemComponentDTO
		
		required init(block: TitleIconsTextListItemComponentDTO) {
			self.block = block
			
			super.init(frame: .zero)
			
			setupUI()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private let headerLabel = UILabel()
		
		private func setupUI() {
			// stack
			let stackView = UIStackView()
			stackView.axis = .vertical
			stackView.spacing = 2
			addSubview(stackView)
			stackView.edgesToSuperview()
			
			// header
			headerLabel.numberOfLines = 0
			stackView.addArrangedSubview(headerLabel)
			headerLabel <~ Style.Label.secondarySubhead
			
			// value
			if let value = block.value, !(value.themedText?.text?.isEmpty ?? true) {
				let valueView = СopyableThemedTextView(block: value)
				stackView.addArrangedSubview(valueView)
			} else {
				let spacer = UIView()
				stackView.addArrangedSubview(spacer)
			}
			
			updateTheme()
		}
		
		// MARK: - Dark Theme Support
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let header = block.header {
				headerLabel <~ StyleExtension.Label(header, for: currentUserInterfaceStyle)
			}
		}
	}
}
