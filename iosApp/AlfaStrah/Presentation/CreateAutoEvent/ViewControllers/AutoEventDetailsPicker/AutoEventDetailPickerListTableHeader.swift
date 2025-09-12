//
//  AutoEventDetailPickerListTableHeader.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 27.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy

class AutoEventDetailPickerListTableHeader: UITableViewHeaderFooterView {
	private let titleLabel = createTitleLabel()
	
	static let id: Reusable<AutoEventDetailPickerListTableHeader> = .fromClass()
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
		// title
		contentView.addSubview(titleLabel)
		titleLabel.topToSuperview()
		titleLabel.horizontalToSuperview()
		titleLabel.bottomToSuperview(offset: -12)
	}
	
	private static func createTitleLabel() -> UILabel {
		let titleLabel = UILabel()
		titleLabel <~ Style.Label.primaryHeadline1
		titleLabel.numberOfLines = 0
		return titleLabel
	}
	
	func configure(
		title: BDUI.ThemedSizedTextComponentDTO?,
		for currentUserInterfaceStyle: UIUserInterfaceStyle
	) {
		if let title {
			titleLabel <~ BDUI.StyleExtension.Label(title, for: currentUserInterfaceStyle)
		}
	}
}
