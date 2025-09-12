//
//  CheckboxInputWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 13.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class CheckboxInputWidgetView: WidgetView<CheckboxInputWidgetDTO> {
		private let contentStackView = UIStackView()
		private let checkBoxButton = CheckboxButtonComponentView()
		private let descriptionLabel = UILabel()
		
		required init(
			block: CheckboxInputWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
			setupTapGestureRecognizer()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupTapGestureRecognizer() {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
		}
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		private func setupUI() {
			addSubview(contentStackView)
			contentStackView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .top
			contentStackView.axis = .horizontal
			contentStackView.distribution = .fill
			contentStackView.spacing = 12
			
			contentStackView.addArrangedSubview(checkBoxButton)
			checkBoxButton.height(20)
			checkBoxButton.widthToHeight(of: checkBoxButton)
			
			checkBoxButton.isSelected = block.isChecked
			setCheckboxStyle(checkBoxButton.isSelected)
			
			checkBoxButton.isEnabled = block.canChange
			
			checkBoxButton.addTarget(self, action: #selector(checkButtonTap(_:)), for: .touchUpInside)
			
			contentStackView.addArrangedSubview(descriptionLabel)
			descriptionLabel <~ Style.Label.secondaryText
			descriptionLabel.numberOfLines = 0
			descriptionLabel.text = block.title?.text
			
			updateTheme()
		}
		
		@objc private func checkButtonTap(_ sender: UIButton) {
			checkBoxButton.isSelected.toggle()
			
			setCheckboxStyle(checkBoxButton.isSelected)
			
			self.replaceFormData(with: checkBoxButton.isSelected)
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			contentStackView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
			
			setCheckboxStyle(checkBoxButton.isSelected)
			
			if let descirption = block.title {
				descriptionLabel <~ StyleExtension.Label(descirption, for: currentUserInterfaceStyle)
			}
		}
		
		private func setCheckboxStyle(_ value: Bool) {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if value {
				checkBoxButton <~ StyleExtension.Checkbox(block.checkedColors, for: currentUserInterfaceStyle)
			} else {
				checkBoxButton <~ StyleExtension.Checkbox(block.uncheckedColors, for: currentUserInterfaceStyle)
			}
		}
	}
}
