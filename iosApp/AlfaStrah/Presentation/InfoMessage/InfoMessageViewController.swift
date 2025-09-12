//
//  InfoMessageViewController.swift
//  AlfaStrah
//
//  Created by vit on 20.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints
import SDWebImage

class InfoMessageViewController: ViewController {
	private let contentStackView = UIStackView()
	private let actionButtonsStackView = UIStackView()
	
	private let infoConainerView = UIView()
	
	private var actionButtons: [(RoundEdgeButton, InfoMessageAction)] = []
	
	struct Input {
		let infoMessage: InfoMessage
	}
	
	struct Output {
		let close: () -> Void
		let retry: () -> Void
		let toChat: () -> Void
	}
	
	var input: Input!
	var output: Output!
			
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		updateTheme()
	}
	
	private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
		setupActionButtonStackView()
		setupInfoConainerView()
		setupContentStackView()
	}
	
	private func setupInfoConainerView() {
		view.addSubview(infoConainerView)
		
		infoConainerView.edgesToSuperview(excluding: .bottom)
		infoConainerView.bottomToTop(of: actionButtonsStackView)
	}

	private func setupContentStackView() {
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .zero
		contentStackView.alignment = .center
		contentStackView.distribution = .fill
		contentStackView.axis = .vertical
		contentStackView.spacing = 0
		contentStackView.backgroundColor = .clear
		
		infoConainerView.addSubview(contentStackView)
		contentStackView.center(in: infoConainerView)
		contentStackView.horizontalToSuperview(
			insets: .horizontal(18)
		)
	}
	
	private func setupActionButtonStackView() {
		view.addSubview(actionButtonsStackView)
		
		actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
		actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 9, left: 18, bottom: 18, right: 18)
		actionButtonsStackView.alignment = .fill
		actionButtonsStackView.distribution = .fill
		actionButtonsStackView.axis = .vertical
		actionButtonsStackView.spacing = 8
		actionButtonsStackView.backgroundColor = .clear
		
		actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
		
		actionButtonsStackView.edgesToSuperview(excluding: .top)
	}
	
	private func setupActionButtons() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		actionButtons.removeAll()
		actionButtonsStackView.subviews.forEach({ $0.removeFromSuperview() })
		
		if let actions = input.infoMessage.actions {
			for action in actions {
				let actionButton = RoundEdgeButton()
				
				actionButton <~ Style.RoundedButton.RoundedParameterizedButton(
					textColor: action.themedTextColor?.color(for: currentUserInterfaceStyle),
					backgroundColor: action.themedBackgroundColor?.color(for: currentUserInterfaceStyle),
					borderColor: .Stroke.strokeAccent
				)
				actionButton.setTitle(action.titleText, for: .normal)
				actionButton.addTarget(
					self,
					action: #selector(actionTap),
					for: .touchUpInside
				)
				actionButton.height(48)
				
				actionButtons.append((actionButton, action))
				
				actionButtonsStackView.addArrangedSubview(actionButton)
			}
		}
	}
	
	private func setupContent() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		contentStackView.subviews.forEach({ $0.removeFromSuperview() })
		
		if let imageUrl = input.infoMessage.themedIcon?.url(for: currentUserInterfaceStyle) {
			let imageView = UIImageView()
			
			imageView.sd_setImage(with: imageUrl)
			
			imageView.height(54)
			imageView.widthToHeight(of: imageView)
			imageView.contentMode = .scaleAspectFit
			
			contentStackView.addArrangedSubview(imageView)
		}
		
		if let titleText = input.infoMessage.titleText {
			contentStackView.addArrangedSubview(spacer(24))
			
			let titleLabel = UILabel()
			titleLabel.numberOfLines = 0
			titleLabel <~ Style.Label.primaryTitle2
			titleLabel.textAlignment = .center
			titleLabel.text = titleText
			
			contentStackView.addArrangedSubview(titleLabel)
		}
		
		if let desciptionText = input.infoMessage.desciptionText {
			contentStackView.addArrangedSubview(spacer(12))
			
			let descriptionLabel = UILabel()
			descriptionLabel.numberOfLines = 0
			descriptionLabel <~ Style.Label.secondaryText
			descriptionLabel.textAlignment = .center
			descriptionLabel.text = desciptionText
			
			contentStackView.addArrangedSubview(descriptionLabel)
		}
	}
	
	@objc private func actionTap(_ sender: RoundEdgeButton) {
		if let buttonEntry = actionButtons.first(where: { $0.0 === sender }) {
			switch buttonEntry.1.type {
				case .close:
					output.close()
				case .retry:
					output.retry()
				case .toChat:
					output.toChat()
			}
		}
	}
	
	// MARK: - Dark theme support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		setupActionButtons()
		setupContent()
	}
}
