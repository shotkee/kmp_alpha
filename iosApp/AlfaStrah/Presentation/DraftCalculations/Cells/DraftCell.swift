//
//  DraftCell.swift
//  AlfaStrah
//
//  Created by vit on 09.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class DraftCell: UITableViewCell {
	static let id: Reusable<DraftCell> = .fromClass()
	
	private let draftView: DraftsCalculationsSectionView = .fromNib()
	
	var selectionModeIsActive: Bool = false {
		didSet {
			draftView.setSelectionMode(selectionModeIsActive)
		}
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setupUI()
	}
	
	private func setupUI() {
		clearStyle()
		
		selectionStyle = .none
		
		contentView.addSubview(draftView)
		
		draftView.topToSuperview(offset: 8)
		draftView.bottomToSuperview(offset: -8)
		draftView.leadingToSuperview()
		draftView.trailingToSuperview()
	}
	
	func configure(
		with draft: DraftsCalculationsData,
		buttonTapAction: @escaping (URL?) -> Void,
		selectionModeEnabled: Bool = false,
		selectionCallback: @escaping () -> Void,
		removeCallback: @escaping () -> Void
	) {
		draftView.setDraftData(draft)
		draftView.setSelectionMode(selectionModeEnabled)
		
		draftView.tapAction = {
			buttonTapAction(draft.url)
		}
		
		draftView.selectionCallback = selectionCallback
		draftView.removeCallback = removeCallback
		
		draftView.addContextMenu()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		draftView.selectionCallback = nil
		draftView.removeCallback = nil
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		draftView.checkbox.isSelected = selected
	}
}

class DraftCategorySectionHeader: UITableViewHeaderFooterView {
	static let id: Reusable<DraftCategorySectionHeader> = .fromClass()
	
	private let draftHeader = DraftsCalculationsHeaderView()
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		addSubview(draftHeader)
		draftHeader.edgesToSuperview()
	}
	
	func set(
		title: String,
		iconUrl: URL?
	) {
		draftHeader.set(
			title: title,
			iconUrl: iconUrl
		)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		draftHeader.reset()
	}
}
