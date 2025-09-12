//
//  DraftsCalculationsHeaderView.swift
//  AlfaStrah
//
//  Created by mac on 24.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import SDWebImage

class DraftsCalculationsHeaderView: UIView {
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
	private let containerView = UIView()

	override init(frame: CGRect) {
		super.init(frame: frame)

		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    private func setupUI() {
        titleLabel <~ Style.Label.primaryTitle2
		titleLabel.numberOfLines = 0
		
		addSubview(containerView)
		containerView.leadingToSuperview(offset: 18)
		containerView.trailingToSuperview(offset: -18)
		containerView.topToSuperview()
		containerView.bottomToSuperview()
		
		containerView.addSubview(titleLabel)
		containerView.addSubview(iconImageView)
		
		iconImageView.height(24)
		iconImageView.widthToHeight(of: iconImageView)
		iconImageView.leadingToSuperview()
		iconImageView.topToSuperview()
		iconImageView.centerY(to: titleLabel)
		
		titleLabel.leadingToTrailing(of: iconImageView, offset: 8)
		titleLabel.topToSuperview()
		titleLabel.bottomToSuperview()
		titleLabel.trailingToSuperview()
    }
	
	private func updateColors(iconTheme: ThemedValue?) {
		guard let iconTheme
		else { return }

		iconImageView.sd_setImage(
			with: iconTheme.url(for: traitCollection.userInterfaceStyle),
			placeholderImage: .Icons.placeholder
		)
	}

	func set(title: String, iconUrl: URL?) {
        titleLabel.text = title
		iconImageView.sd_setImage(
			with: iconUrl,
			placeholderImage: .Icons.placeholder
		)
    }
	
	func reset() {
		iconImageView.sd_cancelCurrentImageLoad()
	}
}
