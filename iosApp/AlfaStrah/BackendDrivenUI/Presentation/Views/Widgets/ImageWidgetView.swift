//
//  ImageWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 28.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ImageWidgetView: WidgetView<ImageWidgetDTO> {
		private let containerView = UIView()
		private let imageView = UIImageView()
		
		private lazy var imageViewHeightConstraint: NSLayoutConstraint = {
			return imageView.height(0)
		}()
		
		required init(
			block: ImageWidgetDTO,
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
			setupContainerView()
			setupImageView()
			updateTheme()
		}
		
		private func setupContainerView() {
			addSubview(containerView)
			containerView.leadingToSuperview(offset: horizontalInset)
			containerView.trailingToSuperview(offset: horizontalInset)
			containerView.topToSuperview()
			containerView.bottomToSuperview()
		}
		
		private func setupImageView() {
			imageView.contentMode = .scaleAspectFit
			containerView.addSubview(imageView)
			
			switch block.align {
				case .center:
					imageView.topToSuperview()
					imageView.bottomToSuperview()
					imageView.center(in: containerView)
					
				case .left:
					imageView.topToSuperview()
					imageView.bottomToSuperview()
					imageView.leadingToSuperview()
					
				case .right:
					imageView.topToSuperview()
					imageView.bottomToSuperview()
					imageView.trailingToSuperview()
					
				case .fill, .none:
					imageView.edgesToSuperview()
			}
			
			imageViewHeightConstraint.isActive = true
		}
		
		private func calculateImageViewHeight(from image: UIImage) -> CGFloat {
			switch block.align {
				case .center, .left, .right:
					return image.size.height * 0.33
					
				case .fill, .none:
					let imageMaxWidth = UIScreen.main.bounds.width - horizontalInset * 2
					
					return imageMaxWidth != 0
					? image.size.height * (imageMaxWidth / image.size.width)
					: image.size.height
					
			}
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
			
			let backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			
			imageView.sd_setImage(
				with: block.image?.url(for: currentUserInterfaceStyle),
				placeholderImage: nil,
				completed: { [weak self] image, err, _, _ in
					guard let self
					else { return }
					
					if let image, err == nil {
						self.imageViewHeightConstraint.constant = self.calculateImageViewHeight(from: image)
					}
				}
			)
		}
	}
}
