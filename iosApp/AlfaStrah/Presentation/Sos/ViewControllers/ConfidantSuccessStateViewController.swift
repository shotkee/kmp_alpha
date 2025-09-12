//
//  ConfidantSuccessStateViewController.swift
//  AlfaStrah
//
//  Created by Makson on 06.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints
import SDWebImage

class ConfidantSuccessStateViewController: ViewController {
	
	// MARK: - Outlets
	private var infoView = UIView()
	private var infoStackView = UIStackView()
	private var iconImageView = UIImageView()
	private var titleLabel = UILabel()
	private var descriptionLabel = UILabel()
	private var buttonsStackView = UIStackView()

	// MARK: - Input
	var input: Input!
	
	struct Input {
		var infoMessage: InfoMessage
	}
	
	// MARK: - Output
	var output: Output!
	
	struct Output {
		var toClose: () -> Void
		var toChat: () -> Void
		var toRetry: () -> Void
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupUI()
	}
	
	private func setupUI() {
		navigationItem.hidesBackButton = true
		navigationItem.leftBarButtonItem = nil
		setupInfoView()
		setupIconImageView()
		setupInfoStackView()
		setupTitleLabel()
		setupDescriptionLabel()
		setupButtonsStackView()
		addButtons()
		updateData()
	}
	
	private func setupInfoView()
	{
		infoView.backgroundColor = .clear
		view.addSubview(infoView)
		infoView.centerXToSuperview()
		infoView.centerYToSuperview()
		infoView.horizontalToSuperview(insets: .horizontal(18))
	}
	
	private func setupIconImageView()
	{
		infoView.addSubview(iconImageView)
		iconImageView.topToSuperview()
		iconImageView.centerXToSuperview()
		iconImageView.height(32)
		iconImageView.widthToHeight(of: iconImageView)
	}
	
	private func setupInfoStackView()
	{
		infoStackView.axis = .vertical
		infoStackView.spacing = 12
		infoView.addSubview(infoStackView)
		infoStackView.edgesToSuperview(excluding: .top)
		infoStackView.topToBottom(of: iconImageView, offset: 24)
	}
	
	private func setupTitleLabel() {
		titleLabel <~ Style.Label.primaryTitle2
		titleLabel.numberOfLines = 0
		titleLabel.text = input.infoMessage.titleText
		titleLabel.textAlignment = .center
		infoStackView.addArrangedSubview(titleLabel)
	}
	
	private func setupDescriptionLabel() {
		descriptionLabel <~ Style.Label.secondaryText
		descriptionLabel.text = input.infoMessage.desciptionText
		descriptionLabel.numberOfLines = 0
		descriptionLabel.textAlignment = .center
		descriptionLabel.isHidden = input.infoMessage.desciptionText?.isEmpty ?? true
		infoStackView.addArrangedSubview(descriptionLabel)
	}
	
	private func setupButtonsStackView()
	{
		buttonsStackView.axis = .vertical
		buttonsStackView.spacing = 10
		view.addSubview(buttonsStackView)
		buttonsStackView.edgesToSuperview(
			excluding: .top,
			insets: .init(
				top: 0,
				left: 15,
				bottom: 15,
				right: 15
			),
			usingSafeArea: true
		)
		
		buttonsStackView.topToBottom(
			of: infoView,
			offset: 16,
			relation: .equalOrGreater
		)
	}
	
	private func addButtons() {
		guard let actions = input.infoMessage.actions
		else { return }
		
		for (index, action) in actions.enumerated() {
			buttonsStackView.addArrangedSubview(
				createButton(action: action, index: index)
			)
		}
	}
	
	private func updateData() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		view.backgroundColor = .Background.backgroundContent
		iconImageView.sd_setImage(
			with: input.infoMessage.themedIcon?.url(for: currentUserInterfaceStyle)
		)
	}
	
	func createButton(action: InfoMessageAction, index: Int) -> UIButton {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		let button = UIButton(type: .custom)
		button.height(48)
		button.setTitle(action.titleText, for: .normal)
		button.backgroundColor = action.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
		button.tintColor = action.themedTextColor?.color(for: currentUserInterfaceStyle)
		button.tag = index
		button.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
		button.layer.cornerRadius = 48 * 0.5
		
		return button
	}
	
	@objc func onTapButton(sender: UIButton) {
		guard let actions = input.infoMessage.actions
		else { return }
		
		if let action = actions[safe: sender.tag] {
			switch action.type {
				case .close:
					output.toClose()
				
				case .retry:
					output.toRetry()
				
				case .toChat:
					output.toChat()
			}
		}
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		updateData()
		buttonsStackView.subviews.forEach { $0.removeFromSuperview() }
		addButtons()
	}
}
