//
//  DraftCalculationWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 15.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import SDWebImage

extension BDUI {
	class DraftCalculationWidgetView: WidgetView<DraftCalculationWidgetDTO> {
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		
		private let headerView = UIView()
		private let calculationNumberTitle = UILabel()
		private let contextMenuButton = UIButton(type: .system)
		private let descriptionView = UIView()
		private let calculationTitleLabel = UILabel()
		private let priceNumberLabel = UILabel()
		private let dividerView = spacer(1)
		private let parameterListContentStackView = UIStackView()
		private let bottomLinesStackView = UIStackView()
		
		private let buttonView = RoundEdgeButton()
		
		required  init(
			block: DraftCalculationWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupTapGestureRecognizer() {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
		}
		
		private func setupUI() {
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = insets(15)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			cardView.set(content: contentStackView)
			
			addSubview(cardView)
			cardView.leadingToSuperview(offset: horizontalInset)
			cardView.topToSuperview()
			cardView.trailingToSuperview(offset: horizontalInset)
			cardView.bottomToSuperview()
			
			setupHeader()
			
			if block.calculationThemedTitle != nil
				|| block.priceThemedText != nil {
				contentStackView.addArrangedSubview(spacer(12))
				setupDescription()
			}
			
			if block.dividerThemedColor != nil {
				contentStackView.addArrangedSubview(spacer(15))
				contentStackView.addArrangedSubview(dividerView)
			}
			
			if block.parameterList?.isEmpty ?? true == false {
				contentStackView.addArrangedSubview(spacer(15))
				setupParameterList()
			}
			
			if block.bottomLines?.isEmpty ?? true == false {
				contentStackView.addArrangedSubview(spacer(15))
				setupBottomLines()
			}
			
			if let button = block.widgetDto {
				contentStackView.addArrangedSubview(spacer(18))
				contentStackView.addArrangedSubview(
					ViewBuilder.constructWidgetView(
						for: button,
						horizontalLayoutOneSideContentInset: 0,
						handleEvent: { events in
							self.handleEvent?(events)
						}
					)
				)
			}
			
			updateTheme()
		}
		
		private func setupHeader() {
			contentStackView.addArrangedSubview(headerView)
			
			calculationNumberTitle.numberOfLines = 0
			calculationNumberTitle <~ Style.Label.secondarySubhead
			calculationNumberTitle.text = block.calculationNumberThemedText?.text
			headerView.addSubview(calculationNumberTitle)
			calculationNumberTitle.topToSuperview()
			calculationNumberTitle.bottomToSuperview()
			calculationNumberTitle.leadingToSuperview()
			let offset = (calculationNumberTitle.font.ascender + calculationNumberTitle.font.descender) * 0.5
			
			headerView.addSubview(menuResponderView)
			menuResponderView.height(36)
			menuResponderView.width(36)
			menuResponderView.leadingToTrailing(of: calculationNumberTitle, offset: 6)
			menuResponderView.centerY(to: calculationNumberTitle, calculationNumberTitle.firstBaselineAnchor, offset: -offset)
			menuResponderView.trailingToSuperview()
			menuResponderView.addSubview(contextMenuButton)
			contextMenuButton.edgesToSuperview()
			
			contextMenuButton.largeTouchAreaEnabled = true
			
			contextMenuButton.addTarget(self, action: #selector(contextMenuTap), for: .touchUpInside)
		}
		
		private func setupDescription() {
			contentStackView.addArrangedSubview(descriptionView)
			descriptionView.addSubview(calculationTitleLabel)
			calculationTitleLabel <~ Style.Label.primaryHeadline1
			calculationTitleLabel.numberOfLines = 0
			
			calculationTitleLabel.edgesToSuperview(excluding: .trailing)
			
			calculationTitleLabel.text = block.calculationThemedTitle?.text
			
			descriptionView.addSubview(priceNumberLabel)
			priceNumberLabel <~ Style.Label.primaryHeadline1
			priceNumberLabel.numberOfLines = 0
			
			priceNumberLabel.leadingToTrailing(of: calculationTitleLabel, offset: 15, relation: .equalOrGreater)
			priceNumberLabel.topToSuperview(relation: .equalOrGreater)
			priceNumberLabel.trailingToSuperview()
			priceNumberLabel.bottomToSuperview(relation: .equalOrLess)
			
			priceNumberLabel.text = block.priceThemedText?.text
		}
		
		private func setupParameterList() {
			parameterListContentStackView.isLayoutMarginsRelativeArrangement = true
			parameterListContentStackView.layoutMargins = .zero
			parameterListContentStackView.alignment = .fill
			parameterListContentStackView.distribution = .fill
			parameterListContentStackView.axis = .vertical
			parameterListContentStackView.spacing = 8
			parameterListContentStackView.backgroundColor = .clear
			
			contentStackView.addArrangedSubview(parameterListContentStackView)
		}
		
		private func setupBottomLines() {
			bottomLinesStackView.isLayoutMarginsRelativeArrangement = true
			bottomLinesStackView.layoutMargins = .zero
			bottomLinesStackView.alignment = .fill
			bottomLinesStackView.distribution = .fill
			bottomLinesStackView.axis = .vertical
			bottomLinesStackView.spacing = 8
			bottomLinesStackView.backgroundColor = .clear
			
			contentStackView.addArrangedSubview(bottomLinesStackView)
		}
		
		private func createLineRowInStack(
			themedText: ThemedTextComponentDTO
		) -> UILabel {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			let lineLabel = UILabel()
			
			lineLabel <~ Style.Label.accentSubhead
			
			lineLabel.text = themedText.text
			lineLabel.textColor = themedText.themedColor?.color(for: currentUserInterfaceStyle)
			
			return lineLabel
		}
		
		private func createParameterRowInStack(
			title: ThemedTextComponentDTO?,
			description: ThemedTextComponentDTO?
		) -> UIStackView {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let stackView = UIStackView()
			stackView.axis = .horizontal
			stackView.distribution = .fill
			stackView.alignment = .fill
			stackView.spacing = 12
			
			let titleItem = UILabel()
			titleItem <~ Style.Label.secondarySubhead
			titleItem.textAlignment = .left
			titleItem.text = title?.text
			titleItem.textColor = title?.themedColor?.color(for: currentUserInterfaceStyle)
			
			titleItem.setContentHuggingPriority(.required, for: .horizontal)
			
			let descriptionItem = UILabel()
			descriptionItem <~ Style.Label.primarySubhead
			descriptionItem.textAlignment = .right
			descriptionItem.text = description?.text
			descriptionItem.textColor = description?.themedColor?.color(for: currentUserInterfaceStyle)
			
			stackView.addArrangedSubview(titleItem)
			stackView.addArrangedSubview(descriptionItem)
			
			return stackView
		}
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			cardView.contentColor = backgroundColor
			contentStackView.backgroundColor = backgroundColor
			
			calculationNumberTitle.textColor = block.calculationNumberThemedText?
				.themedColor?.color(for: currentUserInterfaceStyle)
			?? .Text.textSecondary
			
			SDWebImageManager.shared.loadImage(
				with: block.contextMenu?.themedIcon?.url(for: currentUserInterfaceStyle),
				options: .highPriority,
				progress: nil,
				completed: { image, _, _, _, _, _ in
					self.contextMenuButton.setBackgroundImage(
						image?.resized(newWidth: 24, insets: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 0)),
						for: .normal
					)
				}
			)
			
			calculationTitleLabel.textColor = block.calculationThemedTitle?.themedColor?.color(for: currentUserInterfaceStyle)
			priceNumberLabel.textColor = block.priceThemedText?.themedColor?.color(for: currentUserInterfaceStyle)
			
			dividerView.backgroundColor = block.dividerThemedColor?.color(for: currentUserInterfaceStyle)
			
			if let parameterList = block.parameterList {
				parameterListContentStackView.subviews.forEach({ $0.removeFromSuperview() })
				
				for parameter in parameterList {
					parameterListContentStackView.addArrangedSubview(
						createParameterRowInStack(
							title: parameter.themedTitle,
							description: parameter.themedValue
						)
					)
				}
			}
			
			if let bottomLines = block.bottomLines {
				bottomLinesStackView.subviews.forEach({ $0.removeFromSuperview() })
				
				for line in bottomLines {
					bottomLinesStackView.addArrangedSubview(
						createLineRowInStack(themedText: line)
					)
				}
			}
			
			addContextMenu()
		}
		
		// MARK: - Context menu
		private let menuResponderView = OldStyleMenuResponderView()
		
		private var contextMenuHandler: (() -> Void)?
		
		var selectionCallback: (() -> Void)?
		var removeCallback: (() -> Void)?
		
		@objc func contextMenuTap(_ sender: Any) {
			contextMenuHandler?()
		}
		
		private func addContextMenu() {
			if #available(iOS 14.0, *) {
				cacheContextMenuIcons {
					self.add(contextMenu: self.createContextMenu())
				}
			} else {
				if let items = block.contextMenu?.items {
					contextMenuHandler = { [weak self] in
						guard let self = self
						else { return }
						
						self.menuResponderView.showContextMenu(
							with: items,
							handleEvent: { events in
								self.handleEvent?(events)
							}
						)
					}
				}
			}
		}
		
		@available (iOS 14.0, *)
		private func add(contextMenu: UIMenu?) {
			guard let contextMenu = contextMenu
			else { return }
			
			contextMenuButton.showsMenuAsPrimaryAction = true
			contextMenuButton.menu = contextMenu
		}
		
		@available (iOS 14.0, *)
		private func createContextMenu() -> UIMenu? {
			guard let items = block.contextMenu?.items
			else { return nil }
			
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			var menuElements: [UIMenuElement] = []
			
			for item in items {
				let iconImage = SDImageCache.shared.imageFromMemoryCache(
					forKey: item.themedIcon?.url(for: currentUserInterfaceStyle)?.absoluteString
				)
				
				let action = UIAction(
					title: item.themedText?.text ?? "",
					image: iconImage
				) { _ in
					if let events = item.events {
						self.handleEvent?(events)
					}
				}
				
				menuElements.append(action)
			}
			
			return UIMenu(title: "", children: menuElements)
		}
		
		@available(iOS 14.0, *)
		private func cacheContextMenuIcons(completion: @escaping () -> Void) { // since we cant modify menu element when it was rendered
			guard let items = block.contextMenu?.items
			else { return }
			
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let dispatchGroup = DispatchGroup()
			
			for item in items {
				dispatchGroup.enter()
				
				SDWebImageManager.shared.loadImage(
					with: item.themedIcon?.url(for: currentUserInterfaceStyle),
					options: .highPriority,
					progress: nil,
					completed: { image, _, _, _, _, _ in
						dispatchGroup.leave()
					}
				)
			}
			
			dispatchGroup.notify(queue: .main) {
				completion()
			}
		}
	}
	
	class OldStyleMenuResponderView: UIView {
		private var menuEntries: [(Selector, EventsDTO?)] = []
		private var handleEvent: ((EventsDTO) -> Void)?
		
		func actionMenuItems(_ items: [ContextMenuItemBackendComponent]) -> [UIMenuItem] {
			var menuItems: [UIMenuItem] = []
			
			for item in items {
				if let title = item.themedText?.text {
					let selector = Selector(title) // without colon it cause crash
					
					let menuItem = EventMenuItem(
						title: title,
						action: selector,
						events: item.events
					)
					
					menuItems.append(menuItem)
					
					menuEntries.append((selector, item.events))
				}
			}
			
			return menuItems
		}
		
		// MARK: - UIResponder
		override var canBecomeFirstResponder: Bool {
			true
		}
		
		// since we can't generate selector handlers programmatically we have to use a different approach
		override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
			if let entry = menuEntries.first(where: { $0.0.description == action.description }) {
				if UIMenuController.shared.isMenuVisible {
					// handle action
					if let events = entry.1 {
						self.handleEvent?(events)
					}
				} else {
					// show menu
					return true
				}
			}
			
			return false
		}
		
		func showContextMenu(with items: [ContextMenuItemBackendComponent], handleEvent: @escaping (EventsDTO) -> Void) {
			guard  let superview = self.superview
			else { return }
			
			self.menuEntries.removeAll()
			self.handleEvent = handleEvent
			
			_ = self.becomeFirstResponder()
			
			UIMenuController.shared.menuItems = self.actionMenuItems(items)
			
			UIMenuController.shared.setTargetRect(self.frame, in: superview)
			UIMenuController.shared.setMenuVisible(true, animated: true)
		}
		
		func hideContextMenu() {
			if UIMenuController.shared.isMenuVisible {
				UIMenuController.shared.setMenuVisible(false, animated: true)
			}
		}
	}
	
	class EventMenuItem: UIMenuItem {
		var events: EventsDTO?
		
		convenience init(title: String, action: Selector, events: EventsDTO? = nil) {
			self.init(title: title, action: action)
			
			self.events = events
		}
	}
}
