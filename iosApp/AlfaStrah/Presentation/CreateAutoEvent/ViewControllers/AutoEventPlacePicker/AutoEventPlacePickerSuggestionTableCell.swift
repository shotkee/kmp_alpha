//
//  AutoEventPlacePickerSuggestionTableCell.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 15.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class AutoEventPlacePickerSuggestionTableCell: UITableViewCell {
	
	static let id: Reusable<AutoEventPlacePickerSuggestionTableCell> = .fromClass()
	
	private let titleLabel = UILabel()
	private let subtitleLabel = UILabel()
	
	private var tapCallback: (() -> Void)?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		clearStyle()
		selectionStyle = .none
		
		// vertical stack
		let verticalStack = UIStackView()
		verticalStack.axis = .vertical
		verticalStack.spacing = 2
		contentView.addSubview(verticalStack)
		verticalStack.topToSuperview(offset: 6.5)
		verticalStack.horizontalToSuperview(insets: .horizontal(18))
		verticalStack.bottomToSuperview(offset: -14.5)
		
		// title
		titleLabel <~ Style.Label.primaryText
		titleLabel.numberOfLines = 0
		verticalStack.addArrangedSubview(titleLabel)
		
		// subtitle
		subtitleLabel <~ Style.Label.secondaryText
		subtitleLabel.numberOfLines = 0
		verticalStack.addArrangedSubview(subtitleLabel)
		
		let tap = UITapGestureRecognizer(
			target: self,
			action: #selector(handleTapView(_:))
		)
		
		verticalStack.addGestureRecognizer(tap)
	}
	
	@objc private func handleTapView(_ sender: UITapGestureRecognizer) {
		tapCallback?()
	}
	
	func set(
		title: String,
		subtitle: String,
		selected: @escaping () -> Void
	) {
		self.titleLabel.text = title
		self.subtitleLabel.text = subtitle
		self.tapCallback = selected
	}
}
