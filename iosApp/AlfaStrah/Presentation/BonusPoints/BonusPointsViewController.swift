//
//  BonusPointsViewController.swift
//  AlfaStrah
//
//  Created by vit on 21.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints

class BonusPointsViewController: ViewController,
								 ActionSheetContentViewController,
								 UITableViewDelegate,
								 UITableViewDataSource {
	var animationWhileTransition: (() -> Void)?
	
	struct Input {
		let bonusPointsData: BonusPointsData
	}
	
	struct Output {
		let close: () -> Void
		let backendAction: (BackendAction) -> Void
	}

	var input: Input!
	var output: Output!
	
	private let titleLabel = UILabel()
	private let tableView = UITableView()
	private let headerView = UIView()
	
	private lazy var closeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(.Icons.cross, for: .normal)
		button.tintColor = .Icons.iconAccentThemed
		button.addTarget(self, action: #selector(closeTap), for: .touchUpInside)

		return button
	}()
	
	private lazy var tableViewHeightConstraint: Constraint = {
		return tableView.height(50)
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .Background.backgroundModal
		
		setupHeaderView()
		setupTitleLabel()
		setupCloseButton()
		setupTableView()
	}
	
	private func setupHeaderView() {
		view.addSubview(headerView)
		headerView.leadingToSuperview(offset: 18)
		headerView.trailingToSuperview(offset: 18)
		
		let topOffset: CGFloat = is7IphoneOrLess() ? 10 : 0
		headerView.topToSuperview(offset: topOffset, usingSafeArea: true)
	}
		
	private func setupTitleLabel() {
		headerView.addSubview(titleLabel)
		titleLabel.text = NSLocalizedString("bonus_points_title", comment: "")
		titleLabel.numberOfLines = 0
		titleLabel <~ Style.Label.primaryHeadline1
		
		titleLabel.leadingToSuperview()
		titleLabel.topToSuperview()
		titleLabel.bottomToSuperview()
		titleLabel.trailingToSuperview(offset: 30)
	}
	
	private func setupCloseButton() {
		headerView.addSubview(closeButton)

		closeButton.trailingToSuperview()
		closeButton.height(24)
		closeButton.widthToHeight(of: closeButton)
		
		closeButton.leadingToTrailing(of: titleLabel, offset: 8)
		
		let offset = (titleLabel.font.ascender + titleLabel.font.descender) * 0.5
		closeButton.centerY(to: titleLabel, titleLabel.firstBaselineAnchor, offset: -offset)
	}
	
	@objc private func closeTap() {
		output.close()
	}
	
	private func setupTableView() {
		if #available(iOS 15.0, *) {
			tableView.sectionHeaderTopPadding = 0
		}
		
		tableView.registerReusableCell(BonusCell.id)
		
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.rowHeight = UITableView.automaticDimension
		tableView.backgroundColor = .clear
		
		view.addSubview(tableView)
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		
		tableView.leadingToSuperview()
		tableView.trailingToSuperview()
		tableView.topToBottom(of: headerView, offset: 20)
		tableView.bottomToSuperview(usingSafeArea: true)
		
		tableView.bounces = false
		
		if !is7IphoneOrLess() {
			setTableHeightUsingAutolayout(
				tableView: tableView,
				tableViewHeightContraint: tableViewHeightConstraint
			)
		}
	}
	
	// MARK: - TableView delegate and data source
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		input.bonusPointsData.bonuses.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(BonusCell.id)
		
		let bonus = input.bonusPointsData.bonuses[indexPath.row]
		
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		let showActionButton = bonus.themedButton != nil
		
		cell.configure(
			imageUrl: bonus.themedImage?.url(for: currentUserInterfaceStyle),
			title: bonus.themedTitle?.text,
			titleTextColor: bonus.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle),
			description: bonus.themedDescription?.text,
			descriptionTextColor: bonus.themedDescription?.themedColor?.color(for: currentUserInterfaceStyle),
			amountText: bonus.points?.themedAmount?.text,
			amountTextColor: bonus.points?.themedAmount?.themedColor?.color(for: currentUserInterfaceStyle),
			amountIconUrl: bonus.points?.themedIcon?.url(for: currentUserInterfaceStyle),
			buttonTitle: bonus.themedButton?.action?.title,
			buttonTitleTextColor: bonus.themedButton?.themedTextColor?.color(for: currentUserInterfaceStyle),
			buttonBackgroundColor: bonus.themedButton?.themedBackgroundColor?.color(for: currentUserInterfaceStyle),
			buttonBorderColor: bonus.themedButton?.themedBorderColor?.color(for: currentUserInterfaceStyle),
			showActionButton: showActionButton,
			action: { [weak self] in
				if let backendAction = bonus.themedButton?.action {
					self?.output.backendAction(backendAction)
				}
			}
		)
		
		return cell
	}
	
	// MARK: - Dark theme support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
