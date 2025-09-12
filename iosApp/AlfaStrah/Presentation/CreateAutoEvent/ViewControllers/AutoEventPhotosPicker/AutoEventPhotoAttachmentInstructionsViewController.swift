//
//  AutoEventPhotoAttachmentInstructionsViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 16.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy
import SDWebImage

class AutoEventPhotoAttachmentInstructionsViewController: ViewController {
	private let titleLabel = UILabel()
	private let subtitleLabel = UILabel()
	private let hintImageView = UIImageView()
	private let proceedButton = RoundEdgeButton()
	
	private lazy var hintImageViewHeightConstraint: NSLayoutConstraint = {
		return hintImageView.height(0)
	}()
	
	struct Input {
		let picker: BDUI.OsagoPhotoUploadPickerComponentDTO?
	}
	
	var input: Input!
	
	struct Output {
		let createPhoto: () -> Void
	}
	
	var output: Output!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
	}
	
	private func setupUI() {
		// background
		view.backgroundColor = .Background.backgroundContent
		
		// title
		titleLabel <~ Style.Label.primaryHeadline1
		titleLabel.numberOfLines = 0
		titleLabel.textAlignment = .center
		view.addSubview(titleLabel)
		titleLabel.topToSuperview(
			offset: 16,
			usingSafeArea: true
		)
		titleLabel.horizontalToSuperview(insets: .horizontal(16))
		
		// subtitle
		subtitleLabel <~ Style.Label.secondarySubhead
		subtitleLabel.numberOfLines = 0
		subtitleLabel.textAlignment = .center
		view.addSubview(subtitleLabel)
		subtitleLabel.topToBottom(
			of: titleLabel,
			offset: 6
		)
		subtitleLabel.horizontalToSuperview(insets: .horizontal(16))
		
		// proceed button
		proceedButton <~ Style.RoundedButton.primaryButtonLarge
		view.addSubview(proceedButton)
		proceedButton.bottomToSuperview(
			offset: -15,
			usingSafeArea: true
		)
		proceedButton.horizontalToSuperview(insets: .horizontal(15))
		proceedButton.height(46)
		proceedButton.setTitle(input.picker?.firstScreen?.button?.themedTitle?.text, for: .normal)
		proceedButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
		
		// hint container
		let hintView = UIView()
		hintView.backgroundColor = .clear
		view.addSubview(hintView)
		hintView.topToBottom(of: subtitleLabel)
		hintView.horizontalToSuperview()
		hintView.bottomToTop(of: proceedButton)
		
		// hint stack
		let hintStackView = UIStackView()
		hintStackView.axis = .vertical
		hintStackView.spacing = 24
		hintView.addSubview(hintStackView)
		hintStackView.centerYToSuperview()
		hintStackView.horizontalToSuperview(insets: .horizontal(32))
		
		// hint image
		hintImageView.backgroundColor = .Icons.iconContrast
		hintImageView.contentMode = .scaleAspectFit
		hintImageView.clipsToBounds = false
		hintImageView.layer <~ ShadowAppearance.shadow70pct
		hintImageView.layer.cornerRadius = 16
			
		let imageViewContainer = UIView()
		imageViewContainer.addSubview(hintImageView)
		hintImageView.edgesToSuperview()
		
		hintStackView.addArrangedSubview(imageViewContainer)
		
		// max count
		let maxCountLabel = UILabel()
		
		var maxCountString: String?
		
		if let maxCount = input.picker?.countMax {
			let localized = NSLocalizedString(
				"bdui_osago_photo_count",
				comment: ""
			)
			
			maxCountString = String(
				format: localized,
				locale: .init(identifier: "ru"),
				maxCount
			)
		}
		
		maxCountLabel.text = maxCountString
		maxCountLabel <~ Style.Label.secondarySubhead
		maxCountLabel.numberOfLines = 0
		maxCountLabel.textAlignment = .center
		hintStackView.addArrangedSubview(maxCountLabel)
		
		updateTheme()
	}
	
	@objc func buttonTap() {
		output.createPhoto()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		if let title = input.picker?.firstScreen?.title {
			titleLabel <~ BDUI.StyleExtension.Label(title, for: currentUserInterfaceStyle)
		}
		
		if let subtitle = input.picker?.firstScreen?.subtitle {
			subtitleLabel <~ BDUI.StyleExtension.Label(subtitle, for: currentUserInterfaceStyle)
		}
		
		if let button = input.picker?.firstScreen?.button {
			proceedButton <~ Style.RoundedButton.RoundedParameterizedButton(
				textColor: button.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle),
				backgroundColor: button.themedBackgroundColor?.color(for: currentUserInterfaceStyle),
				borderColor: button.themedBorderColor?.color(for: currentUserInterfaceStyle)
			)
			
			SDWebImageManager.shared.loadImage(
				with: button.leftThemedIcon?.url(for: currentUserInterfaceStyle),
				options: .highPriority,
				progress: nil,
				completed: { image, _, _, _, _, _ in
					self.proceedButton.setImage(image?.resized(newWidth: 20), for: .normal)
				}
			)
		}
				
		hintImageView.sd_setImage(
			with: input.picker?.firstScreen?.image?.url(for: currentUserInterfaceStyle),
			placeholderImage: nil,
			completed: { [weak self] image, err, _, _ in
				guard let self
				else { return }
				
				if let image, err == nil {
					self.hintImageViewHeightConstraint.constant = image.size.height * 0.33
				}
			}
		)
	}
}
