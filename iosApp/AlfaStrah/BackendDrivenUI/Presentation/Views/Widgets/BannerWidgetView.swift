//
//  BannerWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 24.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import AVKit

extension BDUI {
	class BannerWidgetView: WidgetView<BannerWidgetDTO> {
		private let contentStackView = UIStackView()
		private let mediaContentView = UIView()
		private let imageView = UIImageView()
		private let videoPlayerView = AVPlayerView()
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let cardView = CardView()
		
		required init(
			block: BannerWidgetDTO,
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
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			mediaContentView.height(150)
			contentStackView.addArrangedSubview(mediaContentView)
			
			imageView.contentMode = .scaleAspectFill
			
			mediaContentView.addSubview(imageView)
			imageView.edgesToSuperview()
			
			mediaContentView.addSubview(videoPlayerView)
			videoPlayerView.edgesToSuperview()
			
			contentStackView.addArrangedSubview(spacer(9))
			
			titleLabel <~ Style.Label.primaryText
			titleLabel.numberOfLines = 1
			titleLabel.text = block.themedTitle?.text
			
			contentStackView.addArrangedSubview(titleLabel)
			
			contentStackView.addArrangedSubview(spacer(5))
			
			descriptionLabel <~ Style.Label.secondarySubhead
			descriptionLabel.numberOfLines = 2
			descriptionLabel.text = block.themedDescription?.text
			
			contentStackView.addArrangedSubview(descriptionLabel)
			
			let spacerView = UIView()
			spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
			contentStackView.addArrangedSubview(spacerView)
			
			addSubview(cardView)
			
			cardView.edgesToSuperview()
			cardView.cornerRadius = 16
			cardView.set(content: contentStackView)
			
			updateTheme()
		}
		
		@objc private func viewTap() {
			if let events = block.events{
				handleEvent?(events)
			}
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			contentStackView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			
			if let url = block.themedImage?.url(for: currentUserInterfaceStyle) {
				if url.isImageFile {
					mediaContentView.clipsToBounds = true
					imageView.sd_setImage(with: url)
				} else {
					mediaContentView.clipsToBounds = false
					videoPlayerView.showPlayer(for: url)
				}
			}
			
			titleLabel.textColor = block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle)
			descriptionLabel.textColor = block.themedDescription?.themedColor?.color(for: currentUserInterfaceStyle)
		}
	}
	
	class AVPlayerView: UIView {
		private var playerLayer = AVPlayerLayer()
		private var player = AVPlayer()
		private var playerLooper: AVPlayerLooper?
		
		override func layoutSubviews() {
			super.layoutSubviews()
			
			playerLayer.frame = bounds
		}
		
		func showPlayer(for url: URL?) {
			guard let url
			else { return }
			
			MediaContentCache.shared.player(
				for: url,
				reload: { player, looper in
					guard let player, let looper
					else { return }
					
					self.playerLooper = looper
					self.player = player
					
					self.addPlayerLayer(player)
				}
			)
		}
		
		private func addPlayerLayer(_ player: AVQueuePlayer) {
			self.playerLayer.removeFromSuperlayer()
			
			self.playerLayer = AVPlayerLayer(player: player)
			playerLayer.videoGravity = .resizeAspectFill
			
			layer.addSublayer(playerLayer)
			
			player.play()
			
			playerLayer.frame = bounds
		}
	}
}
