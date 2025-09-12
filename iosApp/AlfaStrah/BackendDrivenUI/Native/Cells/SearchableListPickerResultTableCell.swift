//
//  SearchableListPickerResultTableCell.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 04.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy

class SearchableListPickerResultTableCell: UITableViewCell {
	private let titleLabel = createTitleLabel()
	private let subtitleLabel = createSubtitleLabel()
	
	static let id: Reusable<SearchableListPickerResultTableCell> = .fromClass()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(
		title: String,
		subtitle: String?
	) {
		titleLabel.text = title
		subtitleLabel.text = subtitle
		subtitleLabel.isHidden = subtitle == nil
	}
	
	private func setupUI() {
		clearStyle()
		selectionStyle = .none
		
		// content container
		let contentContainer = UIView()
		contentContainer.backgroundColor = .clear
		contentView.addSubview(contentContainer)
		contentContainer.topToSuperview()
		contentContainer.horizontalToSuperview(insets: .horizontal(18))
		contentContainer.bottomToSuperview(offset: -8)
		contentContainer.height(
			52,
			relation: .equalOrGreater
		)
		
		// stack
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 2
		contentContainer.addSubview(stackView)
		stackView.horizontalToSuperview()
		stackView.centerYToSuperview()
		stackView.topToSuperview(
			offset: 6.5,
			relation: .equalOrGreater
		)
				
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(subtitleLabel)
	}
	
	func set(
		item: SearchableListPickerViewController.Item,
		searchString: String?,
		highlightSearch: Bool,
		for currentUserInterfaceStyle: UIUserInterfaceStyle
	) {
		if let title = item.themedSizedTitle {
			titleLabel <~ BDUI.StyleExtension.Label(title, for: currentUserInterfaceStyle)
		} else if let title = item.title {
			titleLabel.text = title
			titleLabel <~ Style.Label.primaryText
		}

		if let subtitle = item.themedSizedText {
			subtitleLabel <~ BDUI.StyleExtension.Label(subtitle, for: currentUserInterfaceStyle)
		} else if let subtitle = item.text {
			subtitleLabel.text = subtitle
			subtitleLabel <~ Style.Label.secondarySubhead
		} else {
			subtitleLabel.removeFromSuperview()
		}
		
		if let searchString,
		   highlightSearch {
			titleLabel.attributedText = titleLabel.attributedText?.mutable.applyingBold(searchString)
			subtitleLabel.attributedText = subtitleLabel.attributedText?.mutable.applyingBold(searchString)
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		self.titleLabel.text = nil
		self.titleLabel.attributedText = nil
		
		self.subtitleLabel.text = nil
		self.subtitleLabel.attributedText = nil
	}
	
	private static func createTitleLabel() -> UILabel {
		let titleLabel = UILabel()
		titleLabel <~ Style.Label.primaryText
		titleLabel.numberOfLines = 0
		return titleLabel
	}
	
	private static func createSubtitleLabel() -> UILabel {
		let titleLabel = UILabel()
		titleLabel <~ Style.Label.secondaryText
		titleLabel.numberOfLines = 0
		return titleLabel
	}
}
