//
//  SwitchToBduiView.swift
//  AlfaStrah
//
//  Created by vit on 01.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

class SwitchToBduiView: UIView {
	private let containerView = UIView()
	private let contentStackView = UIStackView()
	private let imageView = UIImageView()
	
	private let titleLabel = UILabel()
	private let descriptionLabel = UILabel()
	private let linkButton = UIButton(type: .system)
	private let linkButtonTitle = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupUI()
	}
		
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
		
	private func setupUI() {
		addSubview(containerView)
		containerView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
		
		containerView.backgroundColor = .Background.backgroundTertiary
		
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .zero
		contentStackView.alignment = .fill
		contentStackView.distribution = .fill
		contentStackView.axis = .vertical
		contentStackView.spacing = 0
		
		contentStackView.addArrangedSubview(titleLabel)
		titleLabel.numberOfLines = 0
		titleLabel <~ Style.Label.primaryHeadline1
		titleLabel.text = NSLocalizedString("switch_to_bdui_title", comment: "")
		
		contentStackView.addArrangedSubview(spacer(8))
		
		contentStackView.addArrangedSubview(descriptionLabel)
		descriptionLabel.numberOfLines = 0
		descriptionLabel <~ Style.Label.primaryText
		descriptionLabel.text = NSLocalizedString("switch_to_bdui_description", comment: "")
		
		contentStackView.addArrangedSubview(spacer(12))
		
		contentStackView.addArrangedSubview(linkButton)
		linkButton.addSubview(linkButtonTitle)
		
		linkButton.addTarget(self, action: #selector(linkButtonTap), for: .touchUpInside)
		
		linkButtonTitle.edgesToSuperview()
		linkButtonTitle <~ Style.Label.accentButtonSmall
		
		linkButtonTitle.text = NSLocalizedString("return_to_previous_version_action_title", comment: "")
		
		containerView.addSubview(imageView)
		imageView.height(80)
		imageView.width(80)
		imageView.leftToSuperview()
		imageView.topToSuperview(offset: 24)
		imageView.bottomToSuperview(offset: -24, relation: .equalOrLess)
		
		containerView.addSubview(contentStackView)
		contentStackView.topToSuperview(offset: 24)
		contentStackView.leadingToTrailing(of: imageView, offset: 20)
		contentStackView.bottomToSuperview(offset: -24, relation: .equalOrLess)
		contentStackView.trailingToSuperview()
		
		updateTheme()
	}
	
	@objc private func viewTap() {
		switchControllerToBduiVersion()
	}
	
	@objc private func linkButtonTap() {
		switchControllerToBduiVersion()
	}
	
	private func switchControllerToBduiVersion() {		
		ApplicationFlow.shared.reloadHomeTab()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		imageView.image = .Illustrations.update
	}
}
