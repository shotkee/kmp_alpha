//
//  OfficePickerViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/11/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class OfficePickerViewController: ViewController, UISearchBarDelegate {
    struct Input {
		let isDemo: Bool
        let selectedFilters: () -> OfficesFilter?
        let officesListPickerViewController: UIViewController
        let mapPickerViewController: UIViewController
    }

    struct Output {
        let setupLocationServices: () -> Void
        let openFiltersScreen: (_ completion: @escaping (OfficesFilter) -> Void) -> Void
        let setOfficeFilter: (OfficesFilter) -> Void
    }

    struct Notify {
        let changed: (Insurance.Kind?) -> Void
    }

    private enum State: Int {
        case offices = 0
        case map = 1

        var title: String {
            switch self {
                case .offices:
                    return NSLocalizedString("office_picker_cities_list", comment: "")
                case .map:
                    return NSLocalizedString("office_picker_map", comment: "")
            }
        }
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] _ in
            guard let self,
                  self.isViewLoaded
            else { return }

            self.update()
        }
    )

    private func update() {
        if isViewLoaded {
			let selectedFilters = input.selectedFilters()?.officeFilters ?? []
			let searchStringFilter: OfficesFilter.OfficeFilterType = .searchString(searchString)
			
			let isSearchStringFilterSelected = selectedFilters.contains(where: { $0.filterName == searchStringFilter.filterName })
			let isOneFilterSelected = selectedFilters.count == 1
			
			if selectedFilters.isEmpty {
				filterDotContainerView.isHidden = true
			} else if isSearchStringFilterSelected && isOneFilterSelected {
				filterDotContainerView.isHidden = true
			} else {
				filterDotContainerView.isHidden = false
			}
			
            chipsCollection.updateContent(with: filters.map { service in
                (filter: service, isSelected: preselectedServices.contains { $0.filterName == service.filterName })
            })
        }
    }
    private var state: State = .offices {
        didSet {
            updateState()
        }
    }

    private var searchString: String = "" {
        didSet {
            if var selectedFilters = input.selectedFilters() {
                selectedFilters.addFilter(.searchString(searchString))
                output.setOfficeFilter(selectedFilters)
            }
        }
    }

    private var preselectedServices: [OfficesFilter.OfficeFilterType] {
        var servicesInput: [OfficesFilter.OfficeFilterType] = []
        input.selectedFilters()?.officeFilters.forEach {
            switch $0 {
                case .city, .searchString:
                    break
                default:
                    servicesInput.append($0)
            }
        }
        return servicesInput
    }
    private let filters: [OfficesFilter.OfficeFilterType] = [
        .openNow, .sale, .cardPay, .claim, .osagoClaim, . telematicsInstall
    ]

    // MARK: UI
    @IBOutlet private var filtersStackView: UIStackView!
    @IBOutlet private var filtersContainerView: UIView!
    @IBOutlet private var filtersButton: UIButton!
    @IBOutlet private var filterDotContainerView: UIView!
    @IBOutlet private var filterDotView: UIView!
    @IBOutlet private var chipsCollectionContainer: UIView!
    @IBOutlet private var switchView: RMRStyledSwitch!
    @IBOutlet private var officesListView: UIView!
    @IBOutlet private var mapView: UIView!
    @IBOutlet private var gradientView: GradientView!
    private var searchBar: UISearchBar = .init()
    private lazy var chipsCollection: FilterChipsCollectionView = {
        let collection = FilterChipsCollectionView()
        collection.scrollDirection = .horizontal

        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        output.setupLocationServices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        output.setupLocationServices()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        filterDotView.roundCorners(radius: filterDotView.frame.height / 2)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchBar.resignFirstResponder()
    }

    // MARK: - Setup UI

    private func setup() {
        view.backgroundColor = .Background.backgroundContent
        
        filtersButton.setImage(
            .Icons.filterSecondary.tintedImage(withColor: .Icons.iconPrimary),
            for: .normal
        )
                        
        state = .offices

        filterDotView.backgroundColor = .Icons.iconAccent
        filterDotContainerView.isHidden = true

        officesListView.addSubview(input.officesListPickerViewController.view)
        mapView.addSubview(input.mapPickerViewController.view)
        NSLayoutConstraint.activate(Array([
            NSLayoutConstraint.fill(view: input.officesListPickerViewController.view, in: officesListView),
            NSLayoutConstraint.fill(view: input.mapPickerViewController.view, in: mapView),
        ].joined()))

        setupSearchBar()
        setupSwitcher()
        setupCollection()
        setupGradientView()
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("office_search_placeholder", comment: "")
        searchBar.returnKeyType = .search

        navigationItem.titleView = searchBar
    }

    private func setupSwitcher() {
        switchView.style(
            leftTitle: State.offices.title,
            rightTitle: State.map.title,
            titleColor: .Text.textPrimary,
            backgroundColor: .Background.backgroundTertiary,
            selectedTitleColor: .Text.textPrimary,
            selectedBackgroundColor: .Background.segmentedControl,
            titleFont: Style.Font.text,
            selectedBackgroundInset: 3
        )
    }

    private func setupCollection() {
        chipsCollectionContainer.addSubview(chipsCollection)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: chipsCollection, in: chipsCollectionContainer))

        chipsCollection.setup(
            with: "",
            content: filters.map { service in
                (filter: service, isSelected: preselectedServices.contains { $0.filterName == service.filterName })
            },
            chipTapHandler: { [weak self] in
                guard let self
                else { return }
                self.serviceButtonDidTap(with: $0)
            }
        )
    }

    private func updateState() {
        view.endEditing(true)
        officesListView.isHidden = state != .offices
        mapView.isHidden = state != .map
    }
    
    private func setupGradientView() {
        gradientView.startPoint = CGPoint(x: 0, y: 1)
        gradientView.endPoint = CGPoint(x: 1, y: 0)

        gradientView.startColor = .Background.backgroundContent
        gradientView.endColor = .Background.backgroundContent.withAlphaComponent(0.5)
        gradientView.update()
    }

    // MARK: - Actions

    @IBAction func switchTap(_ sender: RMRStyledSwitch) {
        guard let newState = State(rawValue: sender.selectedIndex) else { return }

        state = newState
        searchBar.resignFirstResponder()
    }

    @IBAction func filtersButtonDidTap(_ sender: UIButton) {
        output.openFiltersScreen { self.output.setOfficeFilter($0) }
    }

    private func serviceButtonDidTap(with service: OfficesFilter.OfficeFilterType) {
        if var filter = input.selectedFilters() {
            filter.officeFilters.contains { service.filterName == $0.filterName }
            ? filter.remove([ service ])
            : filter.addFilter(service)
            output.setOfficeFilter(filter)
        }
    }

    // MARK: UISearchBarDelegate

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		self.searchBar.showsCancelButton = input.isDemo 
			? false
			: true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		searchBar.showsCancelButton = input.isDemo
			? false
			: !(searchBar.text?.isEmpty ?? true)
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchString = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchString != searchBar.text {
            searchString = searchBar.text ?? ""
        }

        searchBar.resignFirstResponder()
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        filtersButton.setImage(
            .Icons.filterSecondary.tintedImage(withColor: .Icons.iconPrimary),
            for: .normal
        )
        
        setupGradientView()
    }
}
