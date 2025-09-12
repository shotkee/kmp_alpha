//
//  OfficeCityListViewController.swift
//  AlfaStrah
//
//  Created by Darya Viter on 13.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class OfficeCityListViewController: ViewController, UISearchBarDelegate,
                                    UITableViewDataSource, UITableViewDelegate {
    struct Input {
        let data: () -> NetworkData<[City]>
        let preselectedCities: () -> ([City])
    }

    struct Output {
        let back: () -> Void
        let backWithCities: ([City]) -> Void
        let refresh: () -> Void
    }

    struct Notify {
        let changed: (Insurance.Kind?) -> Void
    }

    @IBOutlet private var emptyListView: UIView!
    @IBOutlet private var emptyListViewTitle: UILabel!
    @IBOutlet private var emptyListViewSubtitle: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var footerStackView: UIStackView!

    private lazy var headerView: UIView = {
        let attributedText = NSAttributedString(
            string: NSLocalizedString("office_city_list_help_text", comment: ""),
            attributes: Style.Label.secondaryText.textAttributes
        )
        let heightForView = ceil(attributedText.boundingRect(
            with: CGSize(width: tableView.frame.width - 36, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).height)

        let label = UILabel()
        label.attributedText = attributedText
        label.numberOfLines = 0

        let viewMargins = UIEdgeInsets(top: 14, left: 18, bottom: 18, right: 18)
        let view = UIView()
        view.addSubview(label)
        view.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: heightForView + viewMargins.top + viewMargins.bottom)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: label,
                in: view,
                margins: viewMargins
            )
        )

        return view
    }()

    private var searchBar: UISearchBar = .init()
    private lazy var cleanAllSelectionButton: RoundEdgeButton = {
        let button = RoundEdgeButton()
        button <~ Style.RoundedButton.oldOutlinedButtonSmall
        button.setTitle(
            NSLocalizedString("office_city_list_clear_selection", comment: ""),
            for: .normal
        )
        button.addTarget(self, action: #selector(clearAllButtonDidTap), for: .touchUpInside)
        return button
    }()
    private lazy var saveAndBackButton: RoundEdgeButton = {
        let button = RoundEdgeButton()
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        button.setTitle(
            NSLocalizedString("office_city_list_save_selection", comment: ""),
            for: .normal
        )
        button.addTarget(self, action: #selector(saveAndBackButtonDidTap), for: .touchUpInside)
        return button
    }()
    private var isNeedToShowCleanAllSelectionButton: Bool = false {
        didSet {
            cleanAllSelectionButton.isHidden = isNeedToShowCleanAllSelectionButton
            tableView.tableHeaderView = searchString.isEmpty ? headerView : nil
        }
    }

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] _ in self?.update() }
    )

    private var searchString: String = "" {
        didSet {
            filteredCities = searchString.isEmpty
                ? cities
                : cities.filter { $0.title.range(of: searchString, options: .caseInsensitive) != nil }

            if filteredCities.isEmpty {
                showZeroListView()
            } else {
                hideZeroView()
            }

            isNeedToShowCleanAllSelectionButton = selectedCities.isEmpty && searchString.isEmpty
            tableView.reloadData()
        }
    }
    private var cities: [City] = []
    private var filteredCities: [City] = []
    private var selectedCities: [(city: City, isSelected: Bool)] = [] {
        didSet {
            isNeedToShowCleanAllSelectionButton = selectedCities.isEmpty && searchString.isEmpty
        }
    }

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update()
        if cities.isEmpty {
            output.refresh()
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableView.contentInset.bottom = footerStackView.frame.height + 20
        tableView.scrollIndicatorInsets.bottom = tableView.contentInset.bottom
    }

    private func setup() {
		view.backgroundColor = .Background.backgroundContent
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 54
        tableView.keyboardDismissMode = .onDrag

        footerStackView.addArrangedSubview(cleanAllSelectionButton)
        footerStackView.addArrangedSubview(saveAndBackButton)
        cleanAllSelectionButton.isHidden = true

        setupSearchBar()
        setupEmptyListView()
        addZeroView()
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("office_city_list_search_placeholder", comment: "")
        searchBar.returnKeyType = .search

        navigationItem.titleView = searchBar
    }

    private func setupEmptyListView() {
        emptyListViewTitle <~ Style.Label.primaryHeadline1
        emptyListViewTitle.text = NSLocalizedString("office_city_list_empty_title", comment: "")
        emptyListViewSubtitle <~ Style.Label.secondaryText
        emptyListViewSubtitle.text = NSLocalizedString("office_city_list_empty_subtitle", comment: "")
        emptyListView.isHidden = true
        emptyListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resetFirstResponder)))
    }

    private func update() {
        if input.preselectedCities().isEmpty {
            selectedCities = []
        } else {
            selectedCities = input.preselectedCities().map { ($0, true) }
        }

        switch input.data() {
            case .loading:
                zeroView?.update(viewModel: .init(kind: .loading))
                showZeroView()
            case .data(let cities):
                self.cities = cities
                if cities.isEmpty {
                    showZeroListView()
                } else {
                    hideZeroView()
                }
                filteredCities = cities
                tableView.reloadData()
            case .error(let error):
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(
                        kind: .always,
                        action: { [weak self] in
                            self?.output.refresh()
                        }
                    ))
                )
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
                isNeedToShowCleanAllSelectionButton = isViewLoaded
        }
        view.endEditing(true)
    }

    func showZeroListView() {
        if isViewLoaded {
            hideZeroView()
            emptyListView.isHidden = false
            cleanAllSelectionButton.isHidden = false
        }
    }

    override func hideZeroView() {
        super.hideZeroView()

        if isViewLoaded {
            emptyListView.isHidden = true
        }
    }

    // MARK: Selectors

    @objc private func clearAllButtonDidTap() {
        searchBar.text = ""
        searchString = ""
        selectedCities = []
        hideZeroView()
        tableView.reloadData()
    }

    @objc private func saveAndBackButtonDidTap() {
        output.backWithCities(selectedCities.map { $0.city })
    }

    @objc private func resetFirstResponder() {
        searchBar.resignFirstResponder()
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredCities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(CityCell.id, indexPath: indexPath)
        let city = filteredCities[indexPath.row]

        if city.id.isEmpty {
            cell.set(city: city, isSelected: selectedCities.isEmpty)
        } else {
            let isSelected = selectedCities.first { $0.city.id == city.id }?.isSelected ?? false
            cell.set(city: city, isSelected: isSelected)
        }

        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()

        if let cell = tableView.cellForRow(at: indexPath) as? CityCell {
            let city = filteredCities[indexPath.row]
            if city.id.isEmpty {
                selectedCities = []
                tableView.reloadData()
            } else {
                let isSelected = selectedCities.first { $0.city.id == city.id }?.isSelected ?? false
                if isSelected {
                    selectedCities = selectedCities.filter { $0.city.id != filteredCities[indexPath.row].id }
                } else {
                    selectedCities.append((city, true))
                }
                cell.set(city: city, isSelected: !isSelected)
            }
            guard let index = filteredCities.firstIndex(where: { $0.id.isEmpty }) else { return }

            let firstCell = tableView.cellForRow(at: IndexPath(row: index, section: indexPath.section)) as? CityCell
            firstCell?.set(city: filteredCities[index], isSelected: selectedCities.isEmpty)
        }
    }

    // MARK: UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchString = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchString != searchBar.text {
            searchString = searchBar.text ?? ""
        }

        searchBar.resignFirstResponder()
    }
}
