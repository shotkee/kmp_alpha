//
//  TwoColumnListWidgetItemView.swift
//  AlfaStrah
//
//  Created by vit on 21.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TwoColumnListWidgetItemView: UIView {
		private let block: TwoColumnListWidgetItemComponentDTO
		
		private let contentStackView = UIStackView()
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let rightTextLabel = UILabel()
		
		required init(
			block: TwoColumnListWidgetItemComponentDTO
		) {
			self.block = block
			
			super.init(frame: .zero)
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .top
			contentStackView.distribution = .fill
			contentStackView.axis = .horizontal
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			addSubview(contentStackView)
			
			contentStackView.edgesToSuperview()
			
			let stackView = UIStackView()
			stackView.isLayoutMarginsRelativeArrangement = true
			stackView.layoutMargins = .zero
			stackView.alignment = .fill
			stackView.distribution = .fill
			stackView.axis = .vertical
			stackView.spacing = 0
			stackView.backgroundColor = .clear
			
			contentStackView.addArrangedSubview(stackView)
			
			titleLabel.text = block.title?.text
			titleLabel <~ Style.Label.primaryHeadline2
			titleLabel.numberOfLines = 0
			stackView.addArrangedSubview(titleLabel)
			
			descriptionLabel.text = block.description?.text
			descriptionLabel <~ Style.Label.secondaryText
			descriptionLabel.numberOfLines = 0
			stackView.addArrangedSubview(descriptionLabel)
			
			let spacer = UIView()
			spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
			contentStackView.addArrangedSubview(spacer)
			
			rightTextLabel.text = block.rightText?.text
			rightTextLabel <~ Style.Label.primaryHeadline1
			rightTextLabel.numberOfLines = 0
			rightTextLabel.textAlignment = .right
			contentStackView.addArrangedSubview(rightTextLabel)
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let title = block.title {
				titleLabel <~ StyleExtension.Label(title, for: currentUserInterfaceStyle)
			}
			
			if let desciption = block.description {
				descriptionLabel <~ StyleExtension.Label(desciption, for: currentUserInterfaceStyle)
			}
			
			if let rightText = block.rightText {
				rightTextLabel <~ StyleExtension.Label(rightText, for: currentUserInterfaceStyle)
			}
		}
	}
}
