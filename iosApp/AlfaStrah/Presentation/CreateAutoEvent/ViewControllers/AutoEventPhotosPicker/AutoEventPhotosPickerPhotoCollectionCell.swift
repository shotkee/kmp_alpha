//
//  AutoEventPhotosPickerPhotoCollectionCell.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 13.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import Lottie

class AutoEventPhotosPickerPhotoCollectionCell: UICollectionViewCell {
	enum State {
		case ready
		case processing
		case error
	}
	
	static let id: Reusable<AutoEventPhotosPickerPhotoCollectionCell> = .fromClass()
	
	var deleteHandler: (() -> Void)?
	var prepareForReuseCallback: (() -> Void)?
	
	private var containerView = UIView()
	private var titleLabel = UILabel()
	private var documentMarkLabel = UILabel()
	private var imagePhotoView = UIImageView()
	private var deleteButton = UIButton(type: .system)
	private var titleBackground = UIView()
	private let stateOverlayView = UIView()
	private let stateIconImageView = UIImageView()
	private lazy var animationView = createAnimationView()

	override init(frame: CGRect) {
		super.init(frame: frame)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setupUI()
	}

	private func setupUI() {
		clearStyle()
		
		titleLabel.numberOfLines = 1
		titleBackground.backgroundColor = .Other.overlayPrimary.withAlphaComponent(0.1)
		titleLabel.font = Style.Font.caption2

		deleteButton.layer.cornerRadius = 12
		deleteButton.layer.masksToBounds = false
		deleteButton.layer <~ ShadowAppearance.shadow70pct
		deleteButton.backgroundColor = .Background.backgroundContent
		deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
		deleteButton.setImage(.Icons.crossSmall.resized(newWidth: 32), for: .normal)
		deleteButton.tintColor = .Icons.iconAccent
		deleteButton.largeTouchAreaEnabled = true

		documentMarkLabel.textColor = .Text.textContrast
		documentMarkLabel.font = Style.Font.caption1
		documentMarkLabel.textAlignment = .center
		documentMarkLabel.numberOfLines = 1
		
		containerView.layer.cornerRadius = Constants.cornerRadius
		containerView.layer.masksToBounds = true
		
		containerView.backgroundColor = .Background.backgroundTertiary
		
		contentView.addSubview(containerView)
		containerView.addSubview(imagePhotoView)
		
		containerView.addSubview(stateOverlayView)
		stateOverlayView.edgesToSuperview()
		
		stateOverlayView.addSubview(stateIconImageView)
		stateIconImageView.center(in: stateOverlayView)
		
		containerView.addSubview(animationView)
		animationView.center(in: containerView)
		animationView.width(48)
		animationView.heightToWidth(of: animationView)
		
		let documentMarkLabelBackground = UIView()
		containerView.addSubview(documentMarkLabelBackground)
		documentMarkLabelBackground.backgroundColor = .Background.backgroundAccent
		documentMarkLabelBackground.layer.cornerRadius = 4
		documentMarkLabelBackground.layer.masksToBounds = true
		
		containerView.addSubview(documentMarkLabel)
		containerView.addSubview(titleBackground)
		containerView.addSubview(titleLabel)
		
		contentView.addSubview(deleteButton)
		
		containerView.edgesToSuperview()
		imagePhotoView.edgesToSuperview()
		
		titleLabel.edgesToSuperview(excluding: .top, insets: insets(6))
		documentMarkLabelBackground.leadingToSuperview(offset: 6)
		documentMarkLabelBackground.topToSuperview(offset: 6)
		documentMarkLabelBackground.trailingToSuperview(offset: -6, relation: .equalOrLess)
		titleBackground.edgesToSuperview(insets: insets(-2))
		documentMarkLabel.edgesToSuperview(insets: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
		
		deleteButton.topToSuperview(offset: -4)
		deleteButton.trailingToSuperview(offset: -4)
		deleteButton.height(32)
		deleteButton.widthToHeight(of: deleteButton)
	}
	
	func update(with state: State) {
		switch state {
			case .ready:
				stateOverlayView.isHidden = true
				stateOverlayView.backgroundColor = .clear
				stateIconImageView.isHidden = true
				titleLabel.textColor = imagePhotoView.image == nil ? .Text.textSecondary : .Text.textContrast
				titleBackground.isHidden = imagePhotoView.image == nil
				animationView.stop()
				
			case .error:
				stateOverlayView.isHidden = false
				stateOverlayView.backgroundColor = imagePhotoView.image == nil ? .Background.backgroundNegativeTint : .clear
				stateIconImageView.isHidden = false
				
				let iconWidth: CGFloat = 24
				stateIconImageView.image = .Icons.exclamation
					.resized(newWidth: iconWidth)?
					.tintedImage(withColor: .Icons.iconAccent)
					.overlay(
						with: UIImage.from(
							color: .Icons.iconContrast,
							size: CGSize(width: iconWidth, height: iconWidth),
							cornerRadius: iconWidth * 0.5
						),
						insets: insets(3)
					)
				
				titleLabel.textColor = imagePhotoView.image == nil ? .Text.textAccent : .Text.textContrast
				titleBackground.isHidden = imagePhotoView.image == nil
				animationView.stop()

			case .processing:
				stateOverlayView.isHidden = false
				stateOverlayView.backgroundColor = .Other.overlayPrimary
				stateIconImageView.isHidden = true
				titleLabel.textColor = .Text.textContrast
				animationView.play()
				
		}
		
		updateSpinner(with: .Icons.iconAccent)
	}
	
	private func createAnimationView() -> AnimationView {
		let animation = Animation.named("red-spinning-loader")
		let animationView = AnimationView(animation: animation)
		animationView.backgroundColor = .clear
		animationView.loopMode = .loop
		animationView.contentMode = .scaleAspectFill
		
		let resistantPriority = UILayoutPriority(rawValue: 990)
		animationView.setContentCompressionResistancePriority(resistantPriority, for: .horizontal)
		animationView.setContentCompressionResistancePriority(resistantPriority, for: .vertical)
		animationView.setContentHuggingPriority(resistantPriority, for: .horizontal)
		animationView.setContentHuggingPriority(resistantPriority, for: .vertical)
		
		animationView.backgroundBehavior = .pauseAndRestore
		
		let keypath = AnimationKeypath(keypath: "Слой-фигура 4.Прямоугольник 1.Заливка 1.Color")
		let colorProvider = ColorValueProvider(UIColor.clear.lottieColorValue)
		animationView.setValueProvider(colorProvider, keypath: keypath)
		
		return animationView
	}
	
	private func updateSpinner(with color: UIColor) {
		let colorProvider = ColorValueProvider(color.lottieColorValue)
		
		let primarySpinnerColorKeypath = AnimationKeypath(keypath: "Слой-фигура 3.Эллипс 1.Обводка 1.Color")
		animationView.setValueProvider(colorProvider, keypath: primarySpinnerColorKeypath)
		
		let secondarySpinnerColorKeypath = AnimationKeypath(keypath: "Слой-фигура 2.Эллипс 1.Обводка 1.Color")
		animationView.setValueProvider(colorProvider, keypath: secondarySpinnerColorKeypath)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
				
		imagePhotoView.sd_cancelCurrentImageLoad()
		prepareForReuseCallback?()
	}
	
	private func updateUI(
		with url: URL?,
		originalName: String?,
		pathExtension: String?
	) {
		if let url {
			imagePhotoView.isHidden = false
						
			imagePhotoView.sd_setImage(with: url)
			titleLabel.textColor = .Text.textContrast
			titleBackground.isHidden = false
			titleBackground.backgroundColor = .Other.overlayPrimary.withAlphaComponent(0.1)
		} else {
			imagePhotoView.isHidden = true
			titleLabel.textColor = .Text.textSecondary
			titleBackground.isHidden = true
			titleBackground.backgroundColor = .Other.overlayPrimary.withAlphaComponent(0.1)
		}
		
		titleLabel.text = originalName
		
		if let pathExtension {
			let badgeText = pathExtension.uppercased()
			
			documentMarkLabel.text = badgeText
			documentMarkLabel.isHidden = badgeText.isEmpty
		} else {
			documentMarkLabel.isHidden = true
		}
	}

	@objc private func deleteAction(_ sender: Any) {
		deleteHandler?()
	}
	
	private enum Constants {
		static let cornerRadius: CGFloat = 8
	}
	
	func configure(
		with url: URL?,
		originalName: String?,
		pathExtension: String?,
		for state: State = .ready
	) {
		updateUI(with: url, originalName: originalName, pathExtension: pathExtension)
		update(with: state)
	}
}
