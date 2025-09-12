//
//  SearchableListPickerViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 04.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import SDWebImage

class SearchableListPickerViewController: ViewController,
										  UITableViewDataSource,
										  UITableViewDelegate {
	struct Notify {
		let setState: (_ state: State) -> Void
	}
	
	private(set) lazy var notify = Notify(
		setState: { [weak self] state in
			guard let self
			else { return }
			
			switch state {
				case .data:
					searchResultsView.isHidden = false
					errorView.isHidden = true
					
				case .error:
					searchResultsView.isHidden = true
					errorView.isHidden = false
			}
		}
	)
	
	struct PickerConfiguration {
		let title: BDUI.ThemedSizedTextComponentDTO?
		let subtitle: BDUI.ThemedSizedTextComponentDTO?
		let button: BDUI.ButtonWidgetDTO?
		let searchInputPlaceholder: BDUI.ThemedSizedTextComponentDTO?
		let searchInputText: BDUI.ThemedSizedTextComponentDTO?
		let highlightSearch: Bool
		let filterBySearchString: Bool
	}
	
	struct Item {
		let title: String?
		let themedSizedTitle: BDUI.ThemedSizedTextComponentDTO?
		let text: String?
		let themedSizedText: BDUI.ThemedSizedTextComponentDTO?
	}
	
	enum State {
		case data
		case error
	}
		
	private lazy var searchInputView = createSearchInputView()
	private lazy var searchResultsTableView = createSearchResultstableView()
	private let searchResultsView = createSearchResultsView()
	private let emptyStateView = createEmptyStateView()
	private let errorView = createErrorView()
	
	private let promptLabel = UILabel()
	private let proceedButton = RoundEdgeButton()
	
	private var searchString: String = "" {
		didSet {
			proceedButton.isHidden = true
			selectedItemIndex = nil
			
			if searchString.isEmpty {
				input.items(self.searchString) { [weak self] items in
					self?.filteredItems = items
				}
			} else {
				input.items(self.searchString) { [weak self] items in
					guard let self
					else { return }
					
					if self.input.pickerConfiguration.filterBySearchString {
						self.filteredItems = items.filter { self.searchCondition(for: $0) }
					} else {
						self.filteredItems = items
					}
				}
			}
		}
	}
	
	private func searchCondition(for item: Item) -> Bool {
		return
			item.themedSizedTitle?.text?.lowercased().contains(searchString.lowercased()) ?? false
			|| item.themedSizedText?.text?.lowercased().contains(searchString.lowercased()) ?? false
			|| item.title?.lowercased().contains(searchString.lowercased()) ?? false
			|| item.text?.lowercased().contains(searchString.lowercased()) ?? false
	}
		
	var filteredItems: [Item] = [] {
		didSet {
			self.reloadSearchResults()
		}
	}
	
	private var selectedItemIndex: Int?
	
	struct Input {
		let items: (_ searchString: String?, _ completion: (([Item]) -> Void)?) -> Void
		let pickerConfiguration: PickerConfiguration
	}
	
	var input: Input!
	
	struct Output {
		let selectedItemIndex: (Int) -> Void
	}
	
	var output: Output!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		
		input.items(self.searchString) { items in
			self.filteredItems = items
		}
		
		self.searchString = input.pickerConfiguration.searchInputText?.text ?? ""
		
		reloadSearchResults()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		searchInputView.textField.becomeFirstResponder()
	}
	
	private func setupUI() {
		// background
		view.backgroundColor = .Background.backgroundContent
				
		// prompt
		promptLabel.numberOfLines = 0
		promptLabel <~ Style.Label.secondaryText
		view.addSubview(promptLabel)
		promptLabel.edgesToSuperview(
			excluding: .bottom,
			insets: .uniform(16)
		)
		
		// search input
		view.addSubview(searchInputView)
		searchInputView.topToBottom(
			of: promptLabel,
			offset: 16
		)
		searchInputView.horizontalToSuperview(insets: .horizontal(16))
		
		// proceed button
		proceedButton <~ Style.RoundedButton.primaryButtonLarge
		view.addSubview(proceedButton)
		proceedButton.bottomToSuperview(
			offset: -15,
			usingSafeArea: true
		)
		proceedButton.horizontalToSuperview(insets: .horizontal(15))
		proceedButton.height(48)
		
		proceedButton.setTitle(input.pickerConfiguration.button?.themedTitle?.text, for: .normal)
		proceedButton.addTarget(self, action: #selector(proceedButtonTap), for: .touchUpInside)
		
		// search results container
		view.addSubview(searchResultsView)
		searchResultsView.topToBottom(of: searchInputView)
		searchResultsView.horizontalToSuperview()
		searchResultsView.bottomToTop(of: proceedButton)
		
		// search results
		searchResultsView.addSubview(searchResultsTableView)
		searchResultsTableView.verticalToSuperview(insets: .vertical(16))
		searchResultsTableView.horizontalToSuperview()
		
		// empty state info
		searchResultsView.addSubview(emptyStateView)
		emptyStateView.topToSuperview(offset: 67)
		emptyStateView.horizontalToSuperview()
		
		// empty state icon
		let emptyStateIconImageView = UIImageView(image: .Icons.search)
		emptyStateIconImageView.contentMode = .scaleAspectFit
		emptyStateIconImageView.tintColor = .Icons.iconAccent
		emptyStateView.addSubview(emptyStateIconImageView)
		emptyStateIconImageView.topToSuperview(offset: 35)
		emptyStateIconImageView.centerXToSuperview()
		emptyStateIconImageView.height(32)
		emptyStateIconImageView.aspectRatio(1)
		
		// empty state title
		let emptyStateTitleLabel = UILabel()
		emptyStateTitleLabel.text = NSLocalizedString("searchable_list_empty_state_title", comment: "")
		emptyStateTitleLabel.numberOfLines = 0
		emptyStateTitleLabel.textAlignment = .center
		emptyStateTitleLabel <~ Style.Label.primaryTitle2
		emptyStateView.addSubview(emptyStateTitleLabel)
		emptyStateTitleLabel.topToBottom(
			of: emptyStateIconImageView,
			offset: 35
		)
		emptyStateTitleLabel.horizontalToSuperview(insets: .horizontal(18))
		
		// empty state subtitle
		let emptyStateSubtitleLabel = UILabel()
		emptyStateSubtitleLabel.text = NSLocalizedString("searchable_list_empty_state_subtitle", comment: "")
		emptyStateSubtitleLabel.numberOfLines = 0
		emptyStateSubtitleLabel.textAlignment = .center
		emptyStateSubtitleLabel <~ Style.Label.secondaryText
		emptyStateView.addSubview(emptyStateSubtitleLabel)
		emptyStateSubtitleLabel.topToBottom(
			of: emptyStateTitleLabel,
			offset: 12
		)
		emptyStateSubtitleLabel.horizontalToSuperview(insets: .horizontal(18))
		
		updateTheme()
	}
	
	private func reloadSearchResults() {
		searchResultsTableView.reloadData()
		searchResultsTableView.isHidden = filteredItems.isEmpty
		proceedButton.isHidden = filteredItems.isEmpty
		emptyStateView.isHidden = !filteredItems.isEmpty
	}
	
	@objc private func proceedButtonTap() {
		if let selectedItemIndex {
			output.selectedItemIndex(selectedItemIndex)
		}
	}
	
	private static func createEmptyStateView() -> UIView {
		let emptyStateView = UIView()
		emptyStateView.backgroundColor = .clear
		return emptyStateView
	}
	
	private static func createErrorView() -> UIView {
		let errorView = UIView()
		errorView.backgroundColor = .clear
		return errorView
	}
	
	private func createSearchInputView() -> CommonTextInput {
		let searchInputView = CommonTextInput()
		searchInputView.shoudValidate = false
		searchInputView.textField.placeholder = input.pickerConfiguration.searchInputPlaceholder?.text
		searchInputView.textField.text = input.pickerConfiguration.searchInputText?.text
		searchInputView.textField.rightViewKind = .clearButton
		
		searchInputView.textField.addTarget(self, action: #selector(searchFieldEditingChanged), for: .editingChanged)
		
		return searchInputView
	}
	
	@objc func searchFieldEditingChanged(sender: CommonTextField) {
		searchString = sender.text ?? ""
	}
	
	private func createSearchResultstableView() -> UITableView {
		let searchResultstableView = UITableView(
			frame: .zero,
			style: .plain
		)
		searchResultstableView.backgroundColor = .clear
		searchResultstableView.separatorStyle = .none
		searchResultstableView.keyboardDismissMode = .onDrag
		searchResultstableView.registerReusableCell(SearchableListPickerResultTableCell.id)
		searchResultstableView.dataSource = self
		searchResultstableView.delegate = self
		return searchResultstableView
	}
	
	private static func createSearchResultsView() -> UIView {
		let searchResultsView = UIView()
		searchResultsView.backgroundColor = .clear
		return searchResultsView
	}
		
	// MARK: - UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.filteredItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let item = self.filteredItems[safe: indexPath.row]
		else { return UITableViewCell() }
		
		let cell = tableView.dequeueReusableCell(
			SearchableListPickerResultTableCell.id,
			indexPath: indexPath
		)
		
		cell.set(
			item: item,
			searchString: self.searchString,
			highlightSearch: self.input.pickerConfiguration.highlightSearch,
			for: traitCollection.userInterfaceStyle
		)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let item = self.filteredItems[safe: indexPath.row]
		else { return }
		
		searchInputView.textField.text = item.themedSizedTitle?.text ?? item.title
		proceedButton.isHidden = false
		
		selectedItemIndex = indexPath.row
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		if let title = input.pickerConfiguration.title {
			navigationItem.titleView = self.createTitleView(
				for: title,
				with: currentUserInterfaceStyle
			)
		}
		
		if let subtitle = input.pickerConfiguration.subtitle {
			promptLabel <~ BDUI.StyleExtension.Label(subtitle, for: currentUserInterfaceStyle)
		}
		
		if let button = input.pickerConfiguration.button {
			proceedButton <~ Style.RoundedButton.RoundedParameterizedButton(
				textColor: button.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle),
				backgroundColor: button.themedBackgroundColor?.color(for: currentUserInterfaceStyle),
				borderColor: button.themedBorderColor?.color(for: currentUserInterfaceStyle)
			)
			
			SDWebImageManager.shared.loadImage(
				with: button.leftThemedIcon?.url(for: currentUserInterfaceStyle),
				options: .highPriority,
				progress: nil,
				completed: { image, _, _, _, _, _ in
					self.proceedButton.setImage(image?.resized(newWidth: 20), for: .normal)
				}
			)
		}
		
		reloadSearchResults()
	}
	
	private func createTitleView(
		for title: BDUI.ThemedSizedTextComponentDTO,
		with userInterfaceStyle: UIUserInterfaceStyle
	) -> UIView {
		let titleStackView = UIStackView()
		
		titleStackView.alignment = .center
		titleStackView.axis = .vertical
		titleStackView.distribution = .fill
		titleStackView.spacing = 2
		
		let titleLabel = UILabel()
		titleLabel <~ BDUI.StyleExtension.Label(title, for: userInterfaceStyle)
		
		titleStackView.addArrangedSubview(titleLabel)
		
		return titleStackView
	}
}
