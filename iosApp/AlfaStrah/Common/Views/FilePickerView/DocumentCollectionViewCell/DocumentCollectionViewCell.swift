//
//  DocumentCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 04.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import Lottie

class DocumentCollectionViewCell: UICollectionViewCell {
	enum State {
		case ready
		case processing
		case error
	}
	
    static let id: Reusable<DocumentCollectionViewCell> = .fromClass()
    
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
        titleLabel.numberOfLines = 1
		titleBackground.backgroundColor = .Other.overlayPrimary.withAlphaComponent(0.1)
        titleLabel.font = Style.Font.caption2

        deleteButton.layer.cornerRadius = 12
        deleteButton.layer.masksToBounds = false
		deleteButton.layer <~ ShadowAppearance.shadow70pct
        deleteButton.backgroundColor = .Background.backgroundContent
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        deleteButton.setImage(.Icons.cross, for: .normal)
        deleteButton.imageEdgeInsets = insets(6)
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
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imagePhotoView)
        imagePhotoView.translatesAutoresizingMaskIntoConstraints = false
		
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
        documentMarkLabelBackground.translatesAutoresizingMaskIntoConstraints = false
        documentMarkLabelBackground.backgroundColor = .Background.backgroundAccent
        documentMarkLabelBackground.layer.cornerRadius = 4
        documentMarkLabelBackground.layer.masksToBounds = true
        
        containerView.addSubview(documentMarkLabel)
        documentMarkLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleBackground)
        titleBackground.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: containerView,
                in: contentView,
                margins: UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
            ) +
            NSLayoutConstraint.fill(
                view: imagePhotoView, in: containerView
            ) + [
                titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
                documentMarkLabelBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
                documentMarkLabelBackground.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
                documentMarkLabelBackground.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -6)
            ] +
            NSLayoutConstraint.fill(
                view: titleBackground,
                in: titleLabel,
                margins: UIEdgeInsets(top: -2, left: -2, bottom: -2, right: -2)
            ) +
            NSLayoutConstraint.fill(
                view: documentMarkLabel,
                in: documentMarkLabelBackground,
                margins: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
            ) + [
                deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor),
                deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                deleteButton.heightAnchor.constraint(equalToConstant: 24),
                deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor, multiplier: 1)
            ]
        )
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
							cornerRadius: iconWidth / 2
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
		
		imagePhotoView.image = nil
		
		prepareForReuseCallback?()
	}
    
    private func updateUI(
		with image: UIImage?,
		originalName: String?,
		pathExtension: String?
	) {
		if let image {			
            imagePhotoView.isHidden = false
						
			imagePhotoView.image = image
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

    @IBAction func deleteAction(_ sender: Any) {
        deleteHandler?()
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 8
    }
    
	func configure(
		with image: UIImage?,
		originalName: String?,
		pathExtension: String?,
		for state: State = .ready
	) {
        updateUI(with: image, originalName: originalName, pathExtension: pathExtension)
		update(with: state)
    }
}
