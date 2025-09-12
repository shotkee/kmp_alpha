//
//  GuaranteeLettersViewController.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 07.04.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class GuaranteeLettersViewController: ViewController,
                                      UITableViewDataSource, UITableViewDelegate,
                                      UISearchBarDelegate
{
    @IBOutlet var headerLabelView: UILabel!
    
    struct Input {
        var insurance: Insurance
        var guaranteeLetters: [GuaranteeLetter]
    }
    struct Output {
        var downloadGuaranteeLetter: (URL) -> Void
        var requestGuaranteeLetter: () -> Void
        var showFiltersScreen: () -> Void
    }
    var input: Input!
    var output: Output!

    private enum DisplayedState {
        case noGuaranteeLetters
        case foundSomething([GuaranteeLetter])
        case nothingFound
    }
    private var displayedState: DisplayedState = .noGuaranteeLetters

    private struct GuaranteeLettersSearchEntry {
        let text: String
        let status: GuaranteeLetter.Status
        let originalIndex: Int
    }
    private var guaranteeLettersSearchEntries: [GuaranteeLettersSearchEntry] = []

    private(set) var activeFilters: [GuaranteeLetter.Status] = []
    private var searchQuery: String = "" {
        didSet {
            self.onSearchQueryChanged()
        }
    }

    private let nothingFoundTableCell = UITableViewCell()
    private var viewDidAppearWasCalled = false

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var requestGuaranteeLetterButton: RoundEdgeButton!
    @IBOutlet private var bottomButtonContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        displayData(guaranteeLetters: input.guaranteeLetters)
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchBar.resignFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateTableBottomInsetIfNeeded()
		updateTableViewHeaderHeightIfNeeded()
    }

    private func updateTableBottomInsetIfNeeded() {
        let bottomInset = bottomButtonContainer.bounds.height + view.safeAreaInsets.bottom
        
        if tableView.contentInset.bottom != bottomInset {
            tableView.contentInset.bottom = bottomInset
        }
    }
	
	private func updateTableViewHeaderHeightIfNeeded() {
		guard let headerView = tableView.tableHeaderView
		else { return }
		
		let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		if headerView.frame.size.height != size.height {
			headerView.frame.size.height = size.height
			tableView.tableHeaderView = headerView
			tableView.layoutIfNeeded()
		}
	}

    private func setup() {
        headerLabelView <~ Style.Label.primaryCaption1
		view.backgroundColor = .Background.backgroundContent
        
        let attributedText = (NSLocalizedString("zero_no_letters_of_guarantee_banner_text", comment: "") <~ Style.TextAttributes.blackInfoSmallText).mutable
        attributedText.applyBold(
            NSLocalizedString("zero_no_letters_of_guarantee_banner_highlighted_text", comment: "")
        )
        headerLabelView.attributedText = attributedText

        navigationItem.title = NSLocalizedString("insurance_letters_of_guarantee", comment: "")

        updateRightBarButtonItem(hasActiveFilters: false)

        setupSearchBar()

		requestGuaranteeLetterButton <~ Style.RoundedButton.redBackground
		requestGuaranteeLetterButton.setTitle(NSLocalizedString("request_letter_of_guarantee", comment: ""), for: .normal)

        addZeroView()
        setupNothingFoundTableCell()

        view.bringSubviewToFront(bottomButtonContainer)
    }

    private func setupSearchBar() {
        searchBar.placeholder = NSLocalizedString("common_search", comment: "")

        if #available(iOS 13.0, *) {
            searchBar.searchTextField.textColor = Style.Color.Palette.darkGray
        }
    }

    private func setupNothingFoundTableCell() {
        let nothingFoundViewModel = ZeroViewModel(
            kind: .custom(
                title: NSLocalizedString("zero_no_matching_letters_of_guarantee", comment: ""),
                message: nil,
                iconKind: .search
            )
        )
        let nothingFoundView = ZeroView()
        nothingFoundView.update(viewModel: nothingFoundViewModel)

        nothingFoundTableCell.contentView.addSubview(nothingFoundView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: nothingFoundView,
                in: nothingFoundTableCell.contentView
            )
        )
    }
    
    private func updateRightBarButtonItem(hasActiveFilters: Bool)
    {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: hasActiveFilters
                           ? "icon-active-filters-navbar"
                           : "icon-filter-navbar"
                          ),
            style: .plain,
            target: self,
            action: #selector(onFilterButton)
        )
    }
    
    func displayData(guaranteeLetters: [GuaranteeLetter]) {
        buildSearchIndex(from: guaranteeLetters)

        displayFilteredData()
    }

    func applyFilters(_ filters: [GuaranteeLetter.Status]) {
        activeFilters = filters
        updateRightBarButtonItem(hasActiveFilters: !filters.isEmpty)

        displayFilteredData()
    }

    @objc private func onFilterButton() {
        output.showFiltersScreen()
    }

    @IBAction private func onRequestGuaranteeLetterButtonTap() {
        output.requestGuaranteeLetter()
    }

    private func buildSearchIndex(from guaranteeLetters: [GuaranteeLetter]) {
        guaranteeLettersSearchEntries = guaranteeLetters.enumerated().map {
            let displayedStrings = GuaranteeLetterCell.getDisplayedStrings(
                for: $0.element
            )
                
            return GuaranteeLettersSearchEntry(
                text: displayedStrings.composeSearchString(),
                status: $0.element.status,
                originalIndex: $0.offset
            )
        }
    }

    private func onSearchQueryChanged() {
        displayFilteredData()
    }

    private func displayFilteredData() {
        if input.guaranteeLetters.isEmpty {
            displayedState = .noGuaranteeLetters
        } else {
            let hasFilters = !activeFilters.isEmpty || !searchQuery.isEmpty

            if hasFilters {
                let filteredLetters = Self.filterGuaranteeLetters(
                    guaranteeLetters: input.guaranteeLetters,
                    searchEntries: guaranteeLettersSearchEntries,
                    activeFilters: activeFilters,
                    searchQuery: searchQuery
                )

                displayedState = filteredLetters.isEmpty
                    ? .nothingFound
                    : .foundSomething(filteredLetters)
                
            } else {
                displayedState = .foundSomething(input.guaranteeLetters)
            }
        }

        switch displayedState {
            case .noGuaranteeLetters:
                let zeroViewModel = ZeroViewModel(
                    kind: .custom(
                        title: "",
                        message: NSLocalizedString("zero_no_letters_of_guarantee", comment: ""),
                        iconKind: .search
                    )
                )
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView(bringToFront: false)
                searchBar.resignFirstResponder()
                tableView.isScrollEnabled = false

            case .foundSomething:
                hideZeroView()
                tableView.isScrollEnabled = true

            case .nothingFound:
                hideZeroView()
                tableView.isScrollEnabled = false
        }

        tableView.reloadData()
    }

    private static func filterGuaranteeLetters(
        guaranteeLetters: [GuaranteeLetter],
        searchEntries: [GuaranteeLettersSearchEntry],
        activeFilters: [GuaranteeLetter.Status],
        searchQuery: String
    ) -> [GuaranteeLetter]
    {
        var filteredEntries = searchEntries

        if !activeFilters.isEmpty {
            filteredEntries = filteredEntries
                .filter { activeFilters.contains($0.status) }
        }

        if !searchQuery.isEmpty {
            let lowercasedSearchQuery = searchQuery.lowercased()
            filteredEntries = filteredEntries
                .filter { $0.text.contains(lowercasedSearchQuery) }
        }

        return filteredEntries
            .map { guaranteeLetters[$0.originalIndex] }
    }

    // MARK: - TableView data source & delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch displayedState {
            case .noGuaranteeLetters:
                return 0
            case .foundSomething(let guaranteeLetters):
                return guaranteeLetters.count
            case .nothingFound:
                return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch displayedState {
            case .noGuaranteeLetters, .nothingFound:
                return 450
            case .foundSomething:
                return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch displayedState {
            case .noGuaranteeLetters:
                return UITableViewCell()

            case .foundSomething(let guaranteeLetters):
                let cell = tableView.dequeueReusableCell(GuaranteeLetterCell.id)

                let guaranteeLetter = guaranteeLetters[indexPath.row]
                cell.configure(
                    guaranteeLetter: guaranteeLetter,
                    downloadGuaranteeLetter: { [weak self] in
                        if let pdfUrl = guaranteeLetter.downloadUrl {
                            self?.output.downloadGuaranteeLetter(pdfUrl)
                        }
                    }
                )

                return cell

            case .nothingFound:
                return nothingFoundTableCell
        }
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

    // MARK: UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchQuery = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchQuery != searchBar.text {
            searchQuery = searchBar.text ?? ""
        }

        searchBar.resignFirstResponder()
    }
    
    @objc private func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
}
