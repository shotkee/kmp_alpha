//
//  DraftsCalculationsViewController.swift
//  AlfaStrah
//
//  Created by mac on 17.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints
import Legacy

class DraftsCalculationsViewController: ViewController,
                                        UISearchBarDelegate,
                                        UICollectionViewDelegate,
                                        UICollectionViewDataSource,
                                        UICollectionViewDelegateFlowLayout,
										UITableViewDelegate,
										UITableViewDataSource,
										UIScrollViewDelegate {
    private var categoriesCollectionHeight: CGFloat = 30
    private var categoriesCollectionTopOffset: CGFloat = 21
    
    enum State {
        case loading
		case demo
        case failure
        case data(DraftsCalculationsCategoriesWithInfo)
    }
    
    struct Notify {
        let update: (_ state: State) -> Void
		let selectionModeEnabled: (_ state: Bool) -> Void
    }
    
    private(set) lazy var notify = Notify(
        update: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(with: state)
        },
		selectionModeEnabled: { [weak self] state in
			self?.bottomButtonsView.isHidden = !state
		}
    )

    private let emptySearchZeroView = ZeroView()
	
	private lazy var emptySearchZeroViewBottomConstraint: NSLayoutConstraint = {
		return emptySearchZeroView.bottomToSuperview(offset: 0)
	}()
	
    private lazy var categoriesCollectionViewHeightConstraint: NSLayoutConstraint = {
		return categoriesCollectionView.height(0)
	}()
		
	private lazy var categoriesViewTopConstraint: Constraint = {
		return categoriesCollectionView.topToBottom(of: searchBar, offset: 0)
	}()

	private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private let pullToRefreshView = PullToRefreshView()
	private let bottomButtonsView = MedicalCardFilesStorageBottomButtonsView()
	
	private var selectionModeIsActive: Bool = false {
		didSet {
			bottomButtonsView.resetSelection()
			bottomButtonsView.isHidden = !selectionModeIsActive

			tableView.reloadData()
			selectAllRows(false, animated: false)
			
			navigationItem.rightBarButtonItem = selectionModeIsActive
				? cancelSelectionModeBarButton
				: activateSelectionModeBarButton
			
			searchBar.isUserInteractionEnabled = !selectionModeIsActive
			searchBar.alpha = selectionModeIsActive ? 0.4 : 1
			
			if selectionModeIsActive {
				searchBar.resignFirstResponder()
			}
		}
	}
	    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		input.appear()
		input.draftCategories(nil)
		
		subscribeForKeyboardNotifications()
    }
    
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		NotificationCenter.default.removeObserver(self)
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
				
		updateTableViewHeaderHeightIfNeeded()
	}
	
    struct Input {
		let appear: () -> Void
        let draftCategories: ((() -> Void)?) -> Void
    }
    
    struct Output {
        let buyInsurance: () -> Void
        let toChat: () -> Void
		let openDraft: (URL?) -> Void
		let deleteDrafts: ([DraftsCalculationsData]) -> Void
    }

    var input: Input!
    var output: Output!
    
    private let operationStatusView = OperationStatusView()
    
    private var draftCategories: [DraftsCalculationsCategory] = [] {
        didSet {
			self.filteredDraftCategories = self.draftCategories
        }
    }
	
	private var filteredDraftCategories: [DraftsCalculationsCategory] = [] {
		didSet {
			tableView.reloadData()
		}
	}

    private lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 9
		layout.sectionInset = .horizontal(Constants.defaultInsets)

        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let additionalInfoTitleLabel = UILabel()
	private let additionalInfoIconImageView = UIImageView()
    
    private let searchBar = UISearchBar()
	
    private func setup() {
		view.backgroundColor = .Background.backgroundContent
        title = NSLocalizedString("main_drafts_calculation_title", comment: "")

		subscribeDidBecomeActiveNotification()
		
        setupSearchBar()
        setupCategories()
        setupOperationStatusView()
        setupZeroView()
		setupTableView()
        setupPullToRefreshView()
		setupBottomButtonsView()
    }
	
	private func setupTableView() {
		if #available(iOS 15.0, *) {
			tableView.sectionHeaderTopPadding = 0
		}
		
		tableView.registerReusableCell(DraftCell.id)
		tableView.registerReusableHeaderFooter(DraftCategorySectionHeader.id)
		
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.separatorStyle = .none
		tableView.allowsMultipleSelection = true
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		tableView.backgroundColor = .clear
		
		view.addSubview(tableView)
		
		tableView.edgesToSuperview(excluding: .top)
		tableView.topToBottom(of: categoriesCollectionView, offset: Constants.defaultTopOffset)
		
		tableView.tableHeaderView = additionalInfoView()
		
		updateTableViewHeaderHeightIfNeeded()
	}
	
	private func updateTableViewHeaderHeightIfNeeded() {
		guard let headerView = tableView.tableHeaderView
		else { return }
		
		let size = headerView.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0))
		if headerView.frame.size.height != size.height {
			headerView.frame.size.height = size.height
			tableView.tableHeaderView = headerView
			tableView.layoutIfNeeded()
		}
	}
    
    private func subscribeDidBecomeActiveNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func didBecomeActiveNotification() {
        input.draftCategories(nil)
    }
	
	private func setupPullToRefreshView() {
		pullToRefreshView.refreshDataCallback = { [weak self] completion in
			guard let self = self
			else { return }
			
			self.searchBar.text = nil
			self.searchBar.showsCancelButton = false
			self.searchBar.endEditing(true)
			
			self.input.draftCategories {
				completion()
			}
		}
			
		pullToRefreshView.scrollView = tableView

		view.insertSubview(pullToRefreshView, at: 0)

		pullToRefreshView.topToBottom(of: categoriesCollectionView, offset: Constants.refreshViewTopOffset)
		pullToRefreshView.horizontalToSuperview()
	}

	// MARK: - UIScrollViewDelegate
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		pullToRefreshView.didScrollCallback(scrollView)

		guard searchBar.isFirstResponder
		else { return }
		
		searchBar.resignFirstResponder()
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		pullToRefreshView.didEndDraggingCallcback(scrollView, willDecelerate: decelerate)
	}
	
	// MARK: - UITableViewDelegate, UITableViewDataSource
	func numberOfSections(in tableView: UITableView) -> Int {
		return filteredDraftCategories.count
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let draftGroup = filteredDraftCategories[safe: section]
		else { return nil }
		
		let header = tableView.dequeueReusableHeaderFooter(DraftCategorySectionHeader.id)

		header.set(title: draftGroup.title, iconUrl: draftGroup.iconThemed?.url(for: traitCollection.userInterfaceStyle))
		
		return draftGroup.title.isEmpty ? nil : header
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let draftGroup = filteredDraftCategories[safe: section]
		else { return }
		
		let header = tableView.dequeueReusableHeaderFooter(DraftCategorySectionHeader.id)
		
		updateTableViewHeaderHeightIfNeeded()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let filteredGroup = filteredDraftCategories[safe: section]
		else { return 0 }
		
		return filteredGroup.drafts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let draft = filteredDraftCategories[safe: indexPath.section]?.drafts[safe: indexPath.row]
		else { return UITableViewCell() }
		
		let cell = tableView.dequeueReusableCell(DraftCell.id)
		
		cell.selectionModeIsActive = selectionModeIsActive
		
		cell.configure(
			with: draft,
			buttonTapAction: { url in
				self.output.openDraft(url)
			},
			selectionModeEnabled: selectionModeIsActive,
			selectionCallback: { [weak self] in
				guard let self = self
				else { return }
				
				self.selectionModeIsActive = true
				
				tableView.selectRow(
					at: IndexPath(row: indexPath.row, section: indexPath.section),
					animated: true,
					scrollPosition: .none
				)
				self.updateStateBottomButtons()
			},
			removeCallback: { [weak self] in
				self?.output.deleteDrafts([draft])
			}
		)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		searchBar.resignFirstResponder()
		
		guard filteredDraftCategories[safe: indexPath.section]?.drafts[safe: indexPath.row] != nil
		else {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		
		if selectionModeIsActive {
			updateStateBottomButtons()
		}
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if selectionModeIsActive {
			updateStateBottomButtons()
		}
	}

    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        operationStatusView.edgesToSuperview()
    }
	
	private func removeDrafts() {
		guard let indexPaths = tableView.indexPathsForSelectedRows
		else { return }
		
		let drafts = indexPaths.map {
			filteredDraftCategories[$0.section].drafts[$0.row]
		}
		
		output.deleteDrafts(drafts)
	}
    
    private func setupZeroView() {
        emptySearchZeroView.update(
            viewModel: .init(
                kind: .custom(
                    title: NSLocalizedString("draft_error_search_title", comment: ""),
                    message: NSLocalizedString("draft_error_search_description", comment: ""),
                    iconKind: .operationFailure
                )
            )
        )
        view.addSubview(emptySearchZeroView)
        emptySearchZeroView.horizontalToSuperview()
        emptySearchZeroView.topToBottom(of: searchBar)
		emptySearchZeroViewBottomConstraint.isActive = true
        zeroView = emptySearchZeroView
        hideZeroView()
    }
    
    // MARK: - ViewController state
    private func update(with state: State) {
		hideZeroView()
		
        switch state {
            case .loading:
				selectionModeIsActive = false
				
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("draft_calculate_loading_title", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
                searchBar.isHidden = true
				navigationItem.rightBarButtonItem = nil
				categoriesCollectionView(show: false)
				tableView.isHidden = true
				
			case .demo:
				selectionModeIsActive = false
				operationStatusView.isHidden = false
				let state: OperationStatusView.State = .info(.init(
					title: "",
					description: NSLocalizedString("common_demo_mode_alert", comment: ""),
					icon: UIImage(named: "preload-search-ico")
				))
				operationStatusView.notify.updateState(state)
				searchBar.isHidden = true
				
				navigationItem.rightBarButtonItem = nil
				categoriesCollectionView(show: false)
				tableView.isHidden = true
				
            case .failure:
				selectionModeIsActive = false
                searchBar.isHidden = true
				
				categoriesCollectionView(show: false)
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("draft_calculate_error_title", comment: ""),
                    description: NSLocalizedString("draft_calculate_error_description", comment: ""),
					icon: .Icons.cross.resized(newWidth: 32)?.withRenderingMode(.alwaysTemplate)
                ))
                
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("common_go_to_chat", comment: ""),
                        isPrimary: false,
                        action: { [weak self] in
                            self?.output.toChat()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("draft_calculate_retry", comment: ""),
                        isPrimary: true,
                        action: { [weak self] in
                            self?.update(with: .loading)
							self?.input.draftCategories(nil)
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
				
				navigationItem.rightBarButtonItem = nil
				categoriesCollectionView(show: false)
				tableView.isHidden = true
				
            case .data(let draftCategoriesWithInfo):
				selectionModeIsActive = false
				
				if draftCategoriesWithInfo.information.isEmpty {
					tableView.tableHeaderView = nil
				} else {
					tableView.tableHeaderView = additionalInfoView()
					additionalInfoTitleLabel.text = draftCategoriesWithInfo.information
				}
				
                if draftCategoriesWithInfo.draftCategories.isEmpty {
					tableView.isHidden = true
					categoriesCollectionView(show: false)
					self.filteredDraftCategories = []
					self.draftCategories = []
					
                    let state: OperationStatusView.State = .info(.init(
                        title: NSLocalizedString("zero_no_drafts", comment: ""),
                        description: NSLocalizedString("zero_no_drafts_description", comment: ""),
						icon: .Illustrations.searchEmpty
                    ))
                    let buttons: [OperationStatusView.ButtonConfiguration] = [
                        .init(
                            title: NSLocalizedString("draft_calculate_cost_policy", comment: ""),
                            isPrimary: true,
                            action: { [weak self] in
                                self?.output.buyInsurance()
                            }
                        )
                    ]
                    operationStatusView.notify.updateState(state)
                    operationStatusView.notify.buttonConfiguration(buttons)
					
                } else {
					tableView.isHidden = false
					
					let draftCategories = draftCategoriesWithInfo.draftCategories
					
					if draftCategories.count <= 1 {
						categoriesCollectionView(show: false)
					} else {
						categoriesCollectionView(show: true)
						
						categoryNames = [NSLocalizedString("common_all_button", comment: "")] +
							draftCategories.filter { $0.shownInFilters }.compactMap { $0.titleInFilters }
						
						categoriesCollectionView.reloadData()
						
						categoriesCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [])
					}
					
					self.draftCategories = draftCategories
                }
				
                searchBar.isHidden = draftCategoriesWithInfo.draftCategories.isEmpty
                operationStatusView.isHidden = !draftCategoriesWithInfo.draftCategories.isEmpty
				
				if draftCategoriesWithInfo.draftCategories.isEmpty {
					navigationItem.rightBarButtonItem = nil
				} else {
					navigationItem.rightBarButtonItem = selectionModeIsActive
						? cancelSelectionModeBarButton
						: activateSelectionModeBarButton
				}
        }
		
		updateTableViewHeaderHeightIfNeeded()
    }
	
	private func categoriesCollectionView(show: Bool) {
		categoriesCollectionView.isHidden = !show
		categoriesViewTopConstraint.constant = !show ? 0 : categoriesCollectionTopOffset
		categoriesCollectionViewHeightConstraint.constant = !show ? 0 : categoriesCollectionHeight
	}
	
    private func setupSearchBar() {
        view.addSubview(searchBar)

        searchBar.searchTextPositionAdjustment = .zero
        searchBar.searchFieldBackgroundPositionAdjustment = .zero
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("common_search", comment: "")
        searchBar.returnKeyType = .search

        searchBar.topToSuperview(offset: 15, usingSafeArea: true)
        searchBar.horizontalToSuperview(insets: .horizontal(10))
		searchBar.topToSuperview(offset: Constants.defaultTopOffset, usingSafeArea: true)
		searchBar.height(Constants.searchBarHeight)
		searchBar.horizontalToSuperview(insets: .horizontal(Constants.searchBarHorizontalInsets))
    }
            
    private func additionalInfoView() -> UIView {
        let additionalBackgroundView = UIView()
		
        let additionalInfoView = UIView()
		additionalInfoView.backgroundColor = .Background.backgroundTertiary
        additionalInfoView.layer.cornerRadius = 10
        additionalBackgroundView.addSubview(additionalInfoView)
		additionalInfoView.edgesToSuperview(insets: insets(Constants.defaultInsets))
        
        let imageView = UIImageView()
        
        additionalInfoView.addSubview(imageView)
		imageView.topToSuperview(offset: Constants.additionalInfoOffset)
        imageView.leadingToSuperview(offset: Constants.additionalInfoOffset)
        imageView.height(18)
        imageView.widthToHeight(of: imageView)
		imageView.image = .Icons.info.resized(newWidth: 18)?.tintedImage(withColor: .Icons.iconAccent)

        additionalInfoView.addSubview(additionalInfoTitleLabel)
		additionalInfoTitleLabel <~ Style.Label.primarySubhead
		additionalInfoTitleLabel.numberOfLines = 0
        additionalInfoTitleLabel.verticalToSuperview(insets: .vertical(Constants.additionalInfoOffset))
        additionalInfoTitleLabel.leadingToTrailing(of: imageView, offset: 9)
		additionalInfoTitleLabel.trailingToSuperview(offset: Constants.additionalInfoOffset)
		
		return additionalBackgroundView
    }
    
    private func setupCategories() {
        view.addSubview(categoriesCollectionView)
        categoriesCollectionView.horizontalToSuperview()
        categoriesCollectionView.topToBottom(of: searchBar, offset: categoriesCollectionTopOffset)
        
        categoriesCollectionView.backgroundColor = .clear
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        categoriesCollectionView.showsHorizontalScrollIndicator = false
        categoriesCollectionView.registerReusableCell(QAHorizontalCollectionCell.id)

        categoriesCollectionViewHeightConstraint = categoriesCollectionView.height(categoriesCollectionHeight)
    }

    private var categoryNames: [String] = []
    	
    private func showAllCategories() {
		self.filteredDraftCategories = self.draftCategories
    }
    
    // MARK: - CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryNames.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let categoryName = categoryNames[safe: indexPath.row]
        else { return .zero }

        let widthLabel = categoryName.width(
            withConstrainedHeight: 18,
            font: Style.Font.text
        )
        
        return CGSize(
            width: widthLabel + 30,
            height: 30
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(QAHorizontalCollectionCell.id, indexPath: indexPath)
		
        if let categoryName = categoryNames[safe: indexPath.row] {
            cell.set(title: categoryName)
        }
		
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showAllCategories()
        } else {
            if let categoryName = categoryNames[safe: indexPath.row] {
				self.filteredDraftCategories = draftCategories.filter { $0.title == categoryName }
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
		
		let firstIndexPath = IndexPath(row: 0, section: 0)
		
		if categoryNames[safe: firstIndexPath.row] != nil {
			categoriesCollectionView.selectItem(at: firstIndexPath, animated: true, scrollPosition: [])
		}
       
		categoriesCollectionView(show: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            showAllCategories()
            return
        }
		
		var filteredSectionBySearchText: [DraftsCalculationsCategory] = []
		
		for section in draftCategories {
			let filteredSection = DraftsCalculationsCategory(
				id: section.id,
				icon: section.icon,
				iconThemed: section.iconThemed,
				titleInFilters: section.titleInFilters,
				title: section.title,
				drafts: section.drafts.filter { filterSection(searchText, in: $0) },
				shownInFilters: section.shownInFilters
			)
			
			if !filteredSection.drafts.isEmpty {
				filteredSectionBySearchText.append(filteredSection)
			}
		}
				
		self.filteredDraftCategories = filteredSectionBySearchText
		
		if filteredSectionBySearchText.isEmpty {
			showZeroView()
			navigationItem.rightBarButtonItem = nil
		}
    }
	
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = AppLocale.currentLocale
		dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
		return dateFormatter
	}()
	
	private func filterSection(_ searchText: String, in draft: DraftsCalculationsData) -> Bool {
		func hasSubstring(_ searchText: String) -> Bool {
			if let price = draft.price,
			   price.lowercased().replacingOccurrences(of: " ", with: "").contains(searchText) {
				return true
			}
			return draft.calculationNumber.lowercased().contains(searchText) ||
			dateFormatter.string(from: draft.date).lowercased().contains(searchText) ||
			draft.title.lowercased().contains(searchText) ||
			draft.parameters.contains {
				$0.title.lowercased().contains(searchText) ||
				$0.value.lowercased().contains(searchText)
			}
		}
		
		return hasSubstring(searchText.lowercased())
	}
	
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		selectAllRows(false, animated: false)
		categoriesCollectionView(show: !(draftCategories.count <= 1))
		navigationItem.rightBarButtonItem = activateSelectionModeBarButton
        searchBar.text = nil
        showAllCategories()
		hideZeroView()
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = !(searchBar.text?.isEmpty ?? true)

        return true
    }
	
	private func setupBottomButtonsView() {
		view.addSubview(bottomButtonsView)
		
		bottomButtonsView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			bottomButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
			bottomButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
		
		bottomButtonsView.set(items: [
			.init(
				icon: .Icons.basket,
				selectedIcon: nil,
				disabledIcon: .Icons.basket,
				action: { [weak self] _ in
					self?.removeDrafts()
				},
				type: .button,
				purpose: .delete,
				isEnabled: false
			),
			.init(
				icon: .Icons.checkbox,
				selectedIcon: .Icons.minusInFilledRoundedBox.tintedImage(withColor: .Icons.iconContrast),
				disabledIcon: .Icons.checkbox,
				action: { [weak self] selection in
					self?.selectAllRows(selection, animated: false)
					self?.updateStateBottomButtons()
				},
				type: .selector,
				purpose: .select,
				isEnabled: true
			)
		])
		
		bottomButtonsView.isHidden = true
	}
	
	private func selectAllRows(_ selection: Bool, animated: Bool) {
		if selection {
			for section in 0..<tableView.numberOfSections {
				for row in 0..<tableView.numberOfRows(inSection: section) {
					tableView.selectRow(
						at: IndexPath(row: row, section: section),
						animated: animated,
						scrollPosition: .none
					)
				}
			}
		} else {
			guard let selectedRows = tableView.indexPathsForSelectedRows
			else { return }
			
			for indexPath in selectedRows {
				tableView.deselectRow(at: indexPath, animated: animated)
			}
		}
	}
	
	private func updateStateBottomButtons(){
		guard let isEmpty = filteredDraftCategories.first?.drafts.isEmpty
		else {
			self.bottomButtonsView.selectButton.isEnabled = false
			self.bottomButtonsView.selectButton.isSelected = false
			self.bottomButtonsView.deleteButton.isEnabled = self.bottomButtonsView.selectButton.isSelected
			return
		}
		
		self.bottomButtonsView.selectButton.isEnabled = !isEmpty
		
		if let indexes = tableView.indexPathsForSelectedRows {
			self.bottomButtonsView.selectButton.isSelected = indexes.count == filteredDraftCategories.reduce(0) { $0 + $1.drafts
				.count }
			self.bottomButtonsView.deleteButton.isEnabled = true
		} else {
			self.bottomButtonsView.selectButton.isSelected = false
			self.bottomButtonsView.deleteButton.isEnabled = false
		}
	}
	
	private func createNavigationBarButton(
		title: String,
		selector: Selector
	) -> UIBarButtonItem {
		
		let barButtonItem = UIBarButtonItem(
			title: title,
			style: .plain,
			target: self,
			action: selector
		)
		
		barButtonItem <~ Style.Button.NavigationItemRed(title: title)

		return barButtonItem
	}
	
	private lazy var activateSelectionModeBarButton = createNavigationBarButton(
		title: NSLocalizedString("common_choose_button", comment: ""),
		selector: #selector(activateSelectionMode)
	)
	
	private lazy var cancelSelectionModeBarButton = createNavigationBarButton(
		title: NSLocalizedString("common_cancel_button", comment: ""),
		selector: #selector(cancelSelectionMode)
	)
	
	@objc private func cancelSelectionMode() {
		selectionModeIsActive = false
	}
	
	@objc private func activateSelectionMode() {
		selectionModeIsActive = true
	}
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
		categoriesCollectionView.reloadData()
	}
	
	// MARK: - Keyboard notifications handling
	private func subscribeForKeyboardNotifications() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillChange),
			name: UIResponder.keyboardWillChangeFrameNotification,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}
	
	@objc func keyboardWillChange(_ notification: NSNotification) {
		moveViewWithKeyboard(notification: notification)
	}
	
	@objc func keyboardWillHide(_ notification: NSNotification) {
		emptySearchZeroViewBottomConstraint.constant = 0
	}
	
	func moveViewWithKeyboard(notification: NSNotification) {
		guard let userInfo = notification.userInfo,
			  let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
		else { return }
		
		let constraintConstant = -keyboardHeight
		
		if  emptySearchZeroViewBottomConstraint.constant != constraintConstant {
			emptySearchZeroViewBottomConstraint.constant = constraintConstant
		}
	}

	struct Constants {
		static let defaultInsets: CGFloat = 18
		static let defaultTopOffset: CGFloat = 15
		static let refreshViewTopOffset: CGFloat = 10
		static let searchBarHeight: CGFloat = 36
		static let searchBarHorizontalInsets: CGFloat = 10
		static let additionalInfoOffset: CGFloat = 12
	}
}
