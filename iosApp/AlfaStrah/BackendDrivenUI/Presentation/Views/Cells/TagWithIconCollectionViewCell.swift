//
//  TagWithIconCollectionViewCell.swift
//  AlfaStrah
//
//  Created by vit on 15.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints

extension BDUI {
	class TagWithIconCollectionViewCell: UICollectionViewCell {
		static let id: Reusable<TagWithIconCollectionViewCell> = .fromClass()
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		let label = UILabel()
		let iconImageView = UIImageView()
		let contentStackView = UIStackView()
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			clearStyle()
			
			contentView.addSubview(contentStackView)
			contentStackView.edgesToSuperview()
			contentStackView.layer.cornerRadius = 6
			contentStackView.layer.masksToBounds = true
			contentStackView.backgroundColor = .Background.backgroundTertiary
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 8)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .horizontal
			contentStackView.spacing = 4
			contentStackView.backgroundColor = .clear
			
			label.lineBreakMode = .byTruncatingTail
		}
		
		func set(_ tag: TagWithIconWidgetDTO) {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			contentStackView.backgroundColor = tag.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			
			if let icon = tag.themedIcon {
				contentStackView.addArrangedSubview(iconImageView)
				iconImageView.width(16)
				iconImageView.heightToWidth(of: iconImageView)
				
				iconImageView.sd_setImage(with: icon.url(for: currentUserInterfaceStyle))
			}
			
			if let title = tag.title {
				contentStackView.addArrangedSubview(label)
				
				label.text = title.text
				
				let color = title.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
				label <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.subhead)
			}
		}
	}
}
