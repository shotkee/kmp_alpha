//
//  ImageTextDescriptionButtonWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 17.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ImageTextDescriptionButtonWidgetView: WidgetView<ImageTextDescriptionButtonWidgetDTO> {
		private let contentStackView = UIStackView()
		private let imageView = UIImageView()
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let containerView = UIView()
		
		private lazy var imageViewHeightConstraint: NSLayoutConstraint = {
			return imageView.height(0)
		}()
		
		required override init(
			block: ImageTextDescriptionButtonWidgetDTO,
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
		
		private func setupUI() {
			addSubview(containerView)
			containerView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .center
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			
			containerView.addSubview(contentStackView)
			contentStackView.edgesToSuperview()
			
			titleLabel <~ Style.Label.primaryTitle2
			titleLabel.numberOfLines = 0
			titleLabel.text = block.themedTitle?.text
			
			descriptionLabel <~ Style.Label.secondaryText
			descriptionLabel.numberOfLines = 0
			descriptionLabel.textAlignment = .center
			descriptionLabel.text = block.themedDescription?.text
			
			imageView.contentMode = .scaleAspectFit
			
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
			
			containerView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .clear
			
			contentStackView.subviews.forEach({ $0.removeFromSuperview() })
			
			if let themedImage = block.themedImage {
				contentStackView.addArrangedSubview(spacer(24))
				contentStackView.addArrangedSubview(imageView)
				contentStackView.addArrangedSubview(spacer(24))
				
				imageView.sd_setImage(
					with: block.themedImage?.url(for: currentUserInterfaceStyle),
					placeholderImage: nil,
					completed: { [weak self] image, err, _, _ in
						guard let self
						else { return }
						
						if let image, err == nil {
							self.imageViewHeightConstraint.constant = image.size.height * 0.34
						}
					}
				)
			}
			
			if let themedTitle = block.themedTitle {
				contentStackView.addArrangedSubview(titleLabel)
				titleLabel.textColor = block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle)
			}
			
			if let themedDescription = block.themedDescription {
				contentStackView.addArrangedSubview(spacer(12))
				contentStackView.addArrangedSubview(descriptionLabel)
				descriptionLabel.textColor = block.themedDescription?.themedColor?.color(for: currentUserInterfaceStyle)
			}
			
			if let button = block.button {
				contentStackView.addArrangedSubview(spacer(24))
				contentStackView.addArrangedSubview(
					ViewBuilder.constructWidgetView(
						for: button,
						handleEvent: { events in
							self.handleEvent?(events)
						}
					)
				)
				contentStackView.addArrangedSubview(spacer(24))
			}
		}
	}
}
