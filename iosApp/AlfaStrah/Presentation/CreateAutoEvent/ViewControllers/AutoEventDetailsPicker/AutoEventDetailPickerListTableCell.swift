//
//  AutoEventDetailPickerListTableCell.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 28.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class AutoEventDetailPickerListTableCell: UITableViewCell {
	
	private let selectionMarkImageView = createSelectionMarkImageView()
	private let separatorView = createSeparatorView()
	private let titleLabel = UILabel()
	
	static let id: Reusable<AutoEventDetailPickerListTableCell> = .fromClass()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		selectionMarkImageView.isHidden = !selected
	}
	
	private func setupUI() {
		clearStyle()
		selectionStyle = .none
		
		// selection mark
		contentView.addSubview(selectionMarkImageView)
		selectionMarkImageView.trailingToSuperview()
		selectionMarkImageView.centerYToSuperview()
		
		// title

		titleLabel <~ Style.Label.primaryText
		titleLabel.numberOfLines = 0
		contentView.addSubview(titleLabel)
		titleLabel.leadingToSuperview()
		titleLabel.trailingToLeading(
			of: selectionMarkImageView,
			offset: -12
		)
		titleLabel.verticalToSuperview(insets: .vertical(19))
		
		// separator
		contentView.addSubview(separatorView)
		separatorView.bottomToSuperview()
		separatorView.horizontalToSuperview()
		separatorView.height(1)
	}
		
	func configure(
		title: BDUI.ThemedSizedTextComponentDTO?,
		for currentUserInterfaceStyle: UIUserInterfaceStyle
	) {
		if let title {
			titleLabel <~ BDUI.StyleExtension.Label(title, for: currentUserInterfaceStyle)
		}
	}
	
	private static func createSelectionMarkImageView() -> UIImageView {
		let selectionMarkImageView = UIImageView()
		selectionMarkImageView.image = .Icons.tick
		selectionMarkImageView.tintColor = .Icons.iconAccentThemed
		return selectionMarkImageView
	}
	
	private static func createSeparatorView() -> UIView {
		let separatorView = UIView()
		separatorView.backgroundColor = .Stroke.divider
		return separatorView
	}
	
	func setSeparatorHidden(_ hidden: Bool) {
		separatorView.isHidden = hidden
	}
}
