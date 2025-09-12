//
//  RateOperatorButtonView.swift
//  AlfaStrah
//
//  Created by vit on 26.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

class RateOperatorButtonView: UIView {
	private let button = UIButton(type: .system)
	private let titleLabel = UILabel()
	private let iconImageView = UIImageView()
	private let accessoryImageView = UIImageView()
	
	var action: (() -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		backgroundColor = .Background.backgroundContent
		
		addSubview(button)
		button.edgesToSuperview()
		button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
		
		let separatorTop = separator()
		addSubview(separatorTop)
		separatorTop.edgesToSuperview(excluding: .bottom)
		
		let separatorBottom = separator()
		addSubview(separatorBottom)
		separatorBottom.edgesToSuperview(excluding: .top)
		
		addSubview(iconImageView)
		addSubview(titleLabel)
		addSubview(accessoryImageView)
		
		iconImageView.centerYToSuperview()
		iconImageView.leadingToSuperview(offset: 18)
		iconImageView.width(16)
		iconImageView.heightToWidth(of: iconImageView)
		
		titleLabel.numberOfLines = 1
		titleLabel <~ Style.Label.accentSubhead

		titleLabel.leadingToTrailing(of: iconImageView, offset: 8)
		titleLabel.centerYToSuperview()
		
		accessoryImageView.height(16)
		accessoryImageView.widthToHeight(of: accessoryImageView)
		
		accessoryImageView.leadingToTrailing(of: titleLabel, offset: 12)
		accessoryImageView.trailingToSuperview(offset: 18)
		accessoryImageView.centerYToSuperview()
		
		updateTheme()
	}
	
	@objc private func buttonTap() {
		action?()
	}
	
	func set(title: String) {
		titleLabel.text = title
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		iconImageView.image = .Icons.star.resized(newWidth: 16)?.tintedImage(withColor: .Icons.iconAccent)
		accessoryImageView.image = .Icons.chevronSmallRight
			.resized(newWidth: 16)?
			.tintedImage(withColor: .Icons.iconAccent)
	}
}
