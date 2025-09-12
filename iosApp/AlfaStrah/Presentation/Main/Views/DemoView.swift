//
//  DemoView.swift
//  AlfaStrah
//
//  Created by Makson on 05.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit


class DemoView: UIView 
{
	private let demoButton = RoundEdgeButton()
	
	var onTapButton: (() -> Void)?
	
	override init(frame: CGRect) 
	{
		super.init(frame: frame)

		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI()
	{
		backgroundColor = .clear
		setupDemoButton()
		
		addSubview(demoButton)
		demoButton.edgesToSuperview(
			excluding: .left,
			insets: .init(
				top: 4.5,
				left: 0,
				bottom: 4.5,
				right: 18
			)
		)
	}
	
	private func setupDemoButton()
	{
		demoButton <~ Style.RoundedButton.primaryWhiteButtonLarge
		demoButton.setTitle(
			NSLocalizedString("demo_button_title", comment: ""),
			for: .normal
		)
		demoButton.semanticContentAttribute = .forceRightToLeft
		demoButton.setImage(
			.Icons.hint
				.resized(newWidth: 24)?
				.tintedImage(withColor: .Icons.iconBlack),
			for: .normal
		)
		demoButton.contentEdgeInsets = UIEdgeInsets(
			top: 4.5,
			left: 12,
			bottom: 4.5,
			right: 6
		)
		demoButton.addTarget(self, action: #selector(demoButtonTap), for: .touchUpInside)
		
		demoButton.height(33)
		demoButton.width(124, relation: .equalOrGreater)
	}
	
	@objc private func demoButtonTap()
	{
		onTapButton?()
	}
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme()
	{
		self.subviews.forEach { $0.removeFromSuperview() }
		setupUI()
	}
}
