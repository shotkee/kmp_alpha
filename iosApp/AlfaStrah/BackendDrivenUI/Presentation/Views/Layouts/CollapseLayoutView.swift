//
//  CollapseLayoutView.swift
//  AlfaStrah
//
//  Created by vit on 18.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints

extension BDUI {
	class CollapseLayoutView: LayoutView<CollapseLayoutDTO>,
							  UITableViewDelegate,
							  UITableViewDataSource {
		let rowSizes: [CGSize]
		
		required init(
			block: CollapseLayoutDTO,
			horizontalInset: CGFloat,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.rowSizes = block.content?.compactMap {
				Self.cellSize(for: $0, with: UIScreen.main.bounds.width)
			} ?? []
			self.content = block.content ?? []
			
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		private let tableView = UITableView()
		
		private var content: [WidgetDTO] = []
		
		private lazy var tableViewHeightConstraint: Constraint = {
			return tableView.height(50)
		}()
		
		private func setupUI() {
			setupTableView()
			
			updateTheme()
		}
		
		private func setupTableView() {
			tableView.registerReusableCell(LayoutViewContainerTableCell.id)
			
			tableView.delegate = self
			tableView.dataSource = self
			
			tableView.separatorStyle = .none
			
			tableView.backgroundColor = .clear
			tableView.bounces = false
			tableView.isScrollEnabled = false
			tableView.showsVerticalScrollIndicator = false
			tableView.showsHorizontalScrollIndicator = false
			
			tableView.clipsToBounds = false
			tableView.layer.masksToBounds = false
			
			let headerView = CollapseLayoutHeaderView()
			
			headerView.set(
				themedHeader: block.themedHeader,
				collapseButton: block.collapseButton,
				pressed: { [weak self] isPressed in
					guard let self,
						  let blockContent = self.block.content
					else { return }
					
					if isPressed {
						self.content.removeAll()
					} else {
						self.content = blockContent
					}
					
					DispatchQueue.main.async { [weak self] in
						guard let self
						else { return }
						
						self.tableView.reloadData()
						self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
					}
				}
			)
			
			let size = headerView.systemLayoutSizeFitting(
				CGSize(width: UIScreen.main.bounds.width - horizontalInset * 2, height: 0),
				withHorizontalFittingPriority: .required,
				verticalFittingPriority: .fittingSizeLevel
			)
			
			headerView.frame.size.height = size.height
			
			tableView.tableHeaderView = headerView
			
			addSubview(tableView)
			tableView.edgesToSuperview()
			tableViewHeightConstraint.isActive = true
			
			setTableHeightUsingAutolayout(
				tableView: tableView,
				tableViewHeightContraint: tableViewHeightConstraint
			)
			
			if let showType = block.showType {
				switch showType {
					case .visible:
						break
					case .invisible:
						headerView.pressed?(true)
				}
			}
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
			
			tableView.reloadData()
		}
		
		// MARK: - UITableViewDelegate, UITableViewDataSource
		func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return self.content.count
		}
		
		func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			guard let selector = self.content[safe: indexPath.row]
			else { return UITableViewCell() }
			
			let cell = tableView.dequeueReusableCell(
				LayoutViewContainerTableCell.id,
				indexPath: indexPath
			)
			
			cell.set(
				horizontalLayoutOneSideContentInset: 16,
				selector: selector,
				handleEvent: { events in
					self.handleEvent?(events)
				}
			)
			
			return cell
		}
		
		func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
			return self.rowSizes[safe: indexPath.row]?.height ?? .leastNormalMagnitude
		}
		
		func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
			return self.rowSizes[safe: indexPath.row]?.height ?? .leastNormalMagnitude
		}
		
		// MARK: - self size calculation
		static private func cellSize(for selector: WidgetDTO, with cellWidth: CGFloat) -> CGSize{
			let cell = LayoutViewContainerTableCell()
			
			cell.set(
				horizontalLayoutOneSideContentInset: 16,
				selector: selector,
				handleEvent: { _ in }
			)
			
			return
				cell.systemLayoutSizeFitting(
					CGSize(width: cellWidth, height: 0),
					withHorizontalFittingPriority: .required,
					verticalFittingPriority: .fittingSizeLevel
				)
		}
	}
	
	private class CollapseLayoutHeaderView: UIView {
		private var themedHeaderComponent: ThemedTextComponentDTO?
		private var collapseButtonComponent: CollapseButtonComponentDTO?
		
		private let collapseButton = UIButton(type: .custom)
		private let titleLabel = UILabel()
		
		var pressed: ((_ isPressed: Bool) -> Void)?
		
		private lazy var collapseButtonShadowView: UIView = {
			let view = UIView()
			
			view.layer.cornerRadius = 16
			view.layer.masksToBounds = false
			view.layer <~ ShadowAppearance.buttonShadow
			view.layer.shadowPath = UIBezierPath(
				roundedRect: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)),
				cornerRadius: bounds.height * 0.5
			).cgPath
			
			view.height(32)
			view.width(32)
			
			return view
		}()
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
			
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			backgroundColor = .clear
			layer.masksToBounds = false
			clipsToBounds = false
			
			let headerView = UIView()
			addSubview(headerView)
			
			headerView.horizontalToSuperview()
			headerView.topToSuperview()
			headerView.bottomToSuperview(offset: -12)
			
			titleLabel <~ Style.Label.primaryHeadline1
			titleLabel.numberOfLines = 0
			titleLabel.lineBreakMode = .byWordWrapping
			
			headerView.addSubview(titleLabel)
			titleLabel.leadingToSuperview(offset: 16)
			titleLabel.topToSuperview(offset: 6, relation: .equalOrGreater)
			titleLabel.bottomToSuperview(offset: -6, relation: .equalOrLess)
			
			headerView.addSubview(collapseButtonShadowView)
			collapseButtonShadowView.leadingToTrailing(of: titleLabel, offset: 8)
			collapseButtonShadowView.trailingToSuperview(offset: 16)
			collapseButtonShadowView.topToSuperview(relation: .equalOrGreater)
			collapseButtonShadowView.bottomToSuperview(relation: .equalOrLess)
			
			collapseButtonShadowView.addSubview(collapseButton)
			collapseButton.layer.cornerRadius = 16
			collapseButton.edgesToSuperview()
			
			collapseButton.addTarget(self, action: #selector(collapseButtonPressed), for: .touchUpInside)
			
			collapseButton.centerY(to: titleLabel.forFirstBaselineLayout)
		}
		
		@objc func collapseButtonPressed(sender: UIButton) {
			collapseButton.isSelected = !collapseButton.isSelected
			
			pressed?(collapseButton.isSelected)
		}
		
		func set(
			themedHeader: ThemedTextComponentDTO?,
			collapseButton: CollapseButtonComponentDTO?,
			pressed: @escaping (_ isPressed: Bool) -> Void
		) {
			titleLabel.text = themedHeader?.text
			
			self.themedHeaderComponent = themedHeader
			self.collapseButtonComponent = collapseButton
			
			self.pressed = pressed
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			titleLabel.textColor = themedHeaderComponent?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
			
			collapseButton.backgroundColor = collapseButtonComponent?
				.themedBackgroundColor?
				.color(for: currentUserInterfaceStyle)
			?? .Background.backgroundSecondary
			
			let iconColor = collapseButtonComponent?.themedIconColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconPrimary
			
			collapseButton.setImage(.Icons.chevronCenteredSmallDown.resized(newWidth: 16)?.tintedImage(withColor: iconColor), for: .selected)
			collapseButton.setImage(.Icons.chevronCenteredSmallUp.resized(newWidth: 16)?.tintedImage(withColor: iconColor), for: .normal)
		}
	}
}
