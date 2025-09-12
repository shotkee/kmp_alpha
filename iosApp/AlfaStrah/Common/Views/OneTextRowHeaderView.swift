//
//  HeaderView.swift
//  AlfaStrah
//
//  Created by vit on 05.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy

class OneTextRowHeaderView: UITableViewHeaderFooterView {
	static let id: Reusable<OneTextRowHeaderView> = .fromClass()
	
	private let label = UILabel()
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		let view = UIView()
		view.backgroundColor = .Background.backgroundAdditional
		
		label <~ Style.Label.primaryHeadline1
		label.numberOfLines = 1
		
		view.addSubview(label)
		label.bottomToSuperview()
		label.leadingToSuperview(offset: 16)
		label.trailingToSuperview(offset: -16)
		label.topToSuperview()
		
		addSubview(view)
		view.edgesToSuperview()
	}
	
	func set(
		title: String
	) {
		label.text = title
	}
}
