//
//  RowWithIconsWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 16.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowWithIconsWidgetView: WidgetView<RowIconsWidgetDTO> {		
		private let buttonContainer = UIButton(type: .system)
		private let badgesStackView = UIStackView()
		
		private var themedTitle: ThemedTextComponentDTO?
		private var themedIcons: [ThemedValueComponentDTO]?
		private var accessoryArrowThemed: ThemedValueComponentDTO?
		
		required init(
			block: RowIconsWidgetDTO,
			horizontalInset: CGFloat = 0,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		private func setupUI() {
			addSubview(buttonContainer)
			buttonContainer.edgesToSuperview()
			
			buttonContainer.addSubview(badgesStackView)
			badgesStackView.edgesToSuperview(excluding: .bottom)
			badgesStackView.bottomToSuperview(relation: .equalOrLess)
			
			badgesStackView.isLayoutMarginsRelativeArrangement = true
			badgesStackView.axis = .horizontal
			badgesStackView.distribution = .fill
			badgesStackView.alignment = .fill
			badgesStackView.spacing = -7
			badgesStackView.isUserInteractionEnabled = false
			
			self.set(block: block, layoutContentInset: horizontalInset)
			
			buttonContainer.addTarget(self, action: #selector(viewTap), for: .touchUpInside)
		}
		
		private func set(
			block: RowIconsWidgetDTO,
			layoutContentInset: CGFloat = 0
		) {
			if let themedIcons = block.icons {
				self.themedIcons = themedIcons
			}
			
			if let themedTitle = block.title {
				self.themedTitle = themedTitle
			}
			
			if let arrow = block.arrow {
				self.accessoryArrowThemed = arrow.themedColor
			}
			
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
			
			buttonContainer.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .clear
			
			badgesStackView.arrangedSubviews.forEach {
				$0.removeFromSuperview()
			}
			
			if let themedIcons {
				for themedIcon in themedIcons {
					let imageView = UIImageView()
					imageView.width(28)
					imageView.heightToWidth(of: imageView)
					imageView.layer.cornerRadius = 14
					imageView.layer.borderColor = UIColor.Background.background.cgColor
					imageView.layer.borderWidth = 2
					imageView.layer.masksToBounds = true
					
					imageView.sd_setImage(with: themedIcon.url(for: currentUserInterfaceStyle))
					imageView.backgroundColor = .clear
					
					badgesStackView.addArrangedSubview(imageView)
				}
			}
			
			if let themedTitle {
				let horizontalSpacer = UIView()
				horizontalSpacer.width(18)
				badgesStackView.addArrangedSubview(horizontalSpacer)
				
				let titleLabel = UILabel()
				titleLabel.numberOfLines = 1
				titleLabel.text = themedTitle.text
				titleLabel <~ Style.Label.accentHeadline1
				
				titleLabel.textColor = themedTitle.themedColor?.color(for: currentUserInterfaceStyle)
				
				badgesStackView.addArrangedSubview(titleLabel)
			}
			
			if let accessoryArrowThemed,
			   let color = accessoryArrowThemed.color(for: currentUserInterfaceStyle) {
				let horizontalSpacer = UIView()
				horizontalSpacer.width(18)
				
				badgesStackView.addArrangedSubview(horizontalSpacer)
				
				let accessoryImageView = UIImageView(image: .Icons.chevronCenteredSmallRight.resized(newWidth: 16)?.tintedImage(withColor: color))
				accessoryImageView.contentMode = .center
				accessoryImageView.height(28)
				accessoryImageView.widthToHeight(of: accessoryImageView)
				badgesStackView.addArrangedSubview(accessoryImageView)
			}
			
			let spacer = UIView()
			spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
			badgesStackView.addArrangedSubview(spacer)
		}
	}
}
