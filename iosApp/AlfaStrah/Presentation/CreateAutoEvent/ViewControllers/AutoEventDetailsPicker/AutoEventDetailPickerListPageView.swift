//
//  AutoEventDetailPickerListPageView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 27.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit

class AutoEventDetailPickerListPageView: UIView,
										 UITableViewDataSource,
										 UITableViewDelegate {
	private let tableView = UITableView(
		frame: .zero,
		style: .grouped
	)
	
	private var updateSelection: (() -> Void)?
	
	private var partsLists: [BDUI.SchemeItemsListComponentDTO] = [] {
		didSet {
			tableView.reloadData()
		}
	}
	
	init() {
		super.init(frame: .zero)
		
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		backgroundColor = .clear
		
		// table
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.allowsMultipleSelection = true
		tableView.registerReusableHeaderFooter(AutoEventDetailPickerListTableHeader.id)
		tableView.registerReusableCell(AutoEventDetailPickerListTableCell.id)
		tableView.dataSource = self
		tableView.delegate = self
		addSubview(tableView)
		tableView.edgesToSuperview()
	}
	
	func configure(
		with partsLists: [BDUI.SchemeItemsListComponentDTO],
		updateSelection: @escaping () -> Void
	) {
		self.partsLists = partsLists
		self.updateSelection = updateSelection
		
		for (sectionIndex, section) in self.partsLists.enumerated() {
			if let items = section.items {
				for (itemIndex, item) in items.enumerated() where item.isSelected {
					let path = IndexPath(row: itemIndex, section: sectionIndex)
					tableView.selectRow(at: path, animated: false, scrollPosition: .none)
				}
			}
		}
	}
	
	// MARK: - UITableViewDataSource
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.partsLists.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.partsLists[section].items?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let items = self.partsLists[safe: indexPath.section]?.items,
			  let part = items[safe: indexPath.row]
		else { return UITableViewCell() }
		
		let cell = tableView.dequeueReusableCell(
			AutoEventDetailPickerListTableCell.id,
			indexPath: indexPath
		)
		
		cell.configure(title: part.title, for: traitCollection.userInterfaceStyle)
		
		cell.setSeparatorHidden(indexPath.row == items.count - 1)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		updateSelection(for: indexPath, selection: true)
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		updateSelection(for: indexPath, selection: false)
	}
	
	private func updateSelection(for indexPath: IndexPath, selection: Bool) {
		guard let items = self.partsLists[safe: indexPath.section]?.items,
			  let part = items[safe: indexPath.row]
		else { return }
		
		part.isSelected = selection
		
		updateSelection?()
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let partsList = self.partsLists[safe: section]
		else { return nil }
		
		let header = tableView.dequeueReusableHeaderFooter(AutoEventDetailPickerListTableHeader.id)
		
		header.configure(title: partsList.title, for: traitCollection.userInterfaceStyle)
		
		return header
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return .init()
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 24
	}
}
