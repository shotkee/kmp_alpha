//
//  IconWithCounterWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 16.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class IconWithCounterWidgetView: WidgetView<IconWithCounterWidgetDTO> {
		private let buttonContainer = UIButton(type: .system)
		private let contentStackView = UIStackView()
		
		private var themedIcon: ThemedValueComponentDTO?
		private var counter: CounterComponentDTO?
		
		required init(
			block: IconWithCounterWidgetDTO,
			horizontalInset: CGFloat = 0,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		private func setupUI() {
			addSubview(buttonContainer)
			buttonContainer.edgesToSuperview()
			
			buttonContainer.addSubview(contentStackView)
			contentStackView.edgesToSuperview(excluding: .bottom)
			contentStackView.bottomToSuperview(relation: .equalOrLess)
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.axis = .horizontal
			contentStackView.distribution = .fill
			contentStackView.alignment = .fill
			contentStackView.spacing = -7
			contentStackView.isUserInteractionEnabled = false
			
			self.set(block: block, layoutContentInset: horizontalInset)
			
			buttonContainer.addTarget(self, action: #selector(viewTap), for: .touchUpInside)
		}
		
		private func set(
			block: IconWithCounterWidgetDTO,
			layoutContentInset: CGFloat = 0
		) {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			self.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
			self.themedIcon = block.themedIcon
			self.counter = block.counter
			
			updateTheme()
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
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		// MARK: - Dark Theme Support
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			self.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
			
			contentStackView.arrangedSubviews.forEach {
				$0.removeFromSuperview()
			}
			let spacer = UIView()
			spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
			contentStackView.addArrangedSubview(spacer)
			
			let iconImageConainerView = UIView()
			iconImageConainerView.height(32)
			iconImageConainerView.widthToHeight(of: iconImageConainerView)
			
			contentStackView.addArrangedSubview(iconImageConainerView)
			
			let iconImageView = UIImageView()
			iconImageConainerView.addSubview(iconImageView)
			
			iconImageView.contentMode = .scaleAspectFit
			iconImageView.sd_setImage(with: themedIcon?.url(for: currentUserInterfaceStyle))
			iconImageView.edgesToSuperview(insets: insets(4))
			
			if let counter {
				let counterLabelContainerView = UIView()
				iconImageConainerView.addSubview(counterLabelContainerView)
				
				let counterLabel = UILabel()
				counterLabelContainerView.addSubview(counterLabel)
				
				counterLabelContainerView.backgroundColor = counter.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Pallete.accentRed
				
				counterLabelContainerView.layer.cornerRadius = 8
				counterLabelContainerView.layer.masksToBounds = true
				
				counterLabelContainerView.centerYToSuperview(offset: -6)
				counterLabelContainerView.leading(to: iconImageConainerView, iconImageConainerView.centerXAnchor)
				counterLabelContainerView.widthToHeight(of: counterLabelContainerView, relation: .equalOrGreater)
				
				counterLabel.edgesToSuperview(insets: UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3))
				
				counterLabel <~ Style.Label.contrastCaption1
				counterLabel.textAlignment = .center
				counterLabel.numberOfLines = 1
				
				counterLabel.textColor = counter.themedText?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textContrast
				counterLabel.text = counter.themedText?.text
			}
		}
	}
}
