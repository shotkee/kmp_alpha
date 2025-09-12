//
//  VzrOnOffPurchaseHistoryViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/17/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class VzrOnOffTripHistoryViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    private enum Constants {
        static let filterViewHeight: CGFloat = 84
        static let defaultOffset: CGFloat = 18
    }

    private struct Section {
        let year: Int
        let subSection: [SubSection]

        struct SubSection {
            let status: VzrOnOffTrip.TripStatus
            let items: [VzrOnOffTrip]
        }
    }

    struct Input {
        let history: (@escaping (Result<[VzrOnOffTrip], AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        let startNewTrip: () -> Void
        let showFilters: ([Int], @escaping (Int) -> Void) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var filterImageView: UIImageView!
    @IBOutlet private var filterLabel: UILabel!
    @IBOutlet private var filterDiscardButton: UIButton!
    @IBOutlet private var filterContainerView: UIView!
    @IBOutlet private var startNewTripButton: RoundEdgeButton!
    @IBOutlet private var gradientView: UIView!
    private var gradientLayer: CAGradientLayer?
    private var sections: [Section] = []
    private var selectedYear: Int? {
        didSet {
            tableView.reloadData()
            updateFilterState(selectedYear: selectedYear)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradientLayer?.frame = gradientView.bounds
        tableView.contentInset.bottom = gradientView.frame.height
    }

    private func setupUI() {
        title = NSLocalizedString("vzr_trip_history_title", comment: "")
        tableView.registerReusableCell(VzrOnOffTripHistoryCell.id)
        startNewTripButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        startNewTripButton.setTitle(NSLocalizedString("vzr_on_off_start_new_trip_action", comment: ""), for: .normal)
        tableView.separatorStyle = .none
        filterImageView.image = UIImage(named: "ic-filter")
        filterLabel <~ Style.Label.primaryText
        filterDiscardButton.setTitle(NSLocalizedString("common_reset_action", comment: ""), for: .normal)
		filterDiscardButton.titleLabel?.font = Style.Font.buttonSmall
        filterDiscardButton.setTitleColor(Style.Color.Palette.darkGray, for: .normal)
        updateFilterState(selectedYear: selectedYear)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor ]
        gradientView.layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
        addZeroView()
        refreshHistory()
    }

    private func updateFilterState(selectedYear: Int?) {
        if let selectedYear = selectedYear {
            filterLabel.text = String(format: NSLocalizedString("vzr_trip_filter_text", comment: ""), "\(selectedYear)")
            filterDiscardButton.isHidden = false
        } else {
            filterLabel.text = NSLocalizedString("vzr_filter_all_trips", comment: "")
            filterDiscardButton.isHidden = true
        }
    }

    private func refreshHistory() {
        showZeroView()
        zeroView?.update(viewModel: .init(kind: .loading))
        input.history { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let history):
                    self.updateHistoryViewStruct(history)
                    if history.isEmpty {
                        self.zeroView?.update(viewModel: .init(kind: .emptyList))
                    } else {
                        self.hideZeroView()
                    }
                case .failure(let error):
                    self.updateHistoryViewStruct([])
                    let zeroViewModel = ZeroViewModel(
                        kind: .error(error, retry: .init(kind: .unreachableErrorOnly, action: { [weak self] in self?.refreshHistory() })),
                        buttons: OperationStatusView.ButtonConfiguration.mainScreenOtChat
                    )
                    self.zeroView?.update(viewModel: zeroViewModel)
            }
        }
    }

    private func updateHistoryViewStruct(_ history: [VzrOnOffTrip]) {
        guard !history.isEmpty else { return }

        sections = []
        var years: Set<Int> = []
        history.forEach { $0.years.forEach { years.insert($0) } }
        for year in years.sorted(by: >) {
            let tripsInYear = history.filter { $0.years.contains(year) }
            let activeTrips = tripsInYear.filter { $0.status == .active }
            let plannedTrips = tripsInYear.filter { $0.status == .planned }
            let passedTrips = tripsInYear.filter { $0.status == .passed }
            var subSections: [Section.SubSection] = []
            if !activeTrips.isEmpty { subSections.append(.init(status: .active, items: activeTrips)) }
            if !plannedTrips.isEmpty { subSections.append(.init(status: .planned, items: plannedTrips)) }
            if !passedTrips.isEmpty { subSections.append(.init(status: .passed, items: passedTrips)) }
            sections.append(.init(year: year, subSection: subSections))
        }
        tableView.reloadData()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 102
        let shouldHideFilter = years.count <= 1
        filterContainerView.isHidden = shouldHideFilter
        tableView.contentInset.top = shouldHideFilter ? Constants.defaultOffset : filterContainerView.frame.height
    }

    @IBAction private func filterTap(_ sender: UIButton) {
        output.showFilters(sections.map { $0.year }) { [weak self] year in
            self?.selectedYear = year
        }
    }

    @IBAction func discardTap(_ sender: UIButton) {
        selectedYear = nil
    }

    @IBAction func startNewTripTap(_ sender: UIButton) {
        output.startNewTrip()
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        if let selectedYear = selectedYear {
            return sections.filter { $0.year == selectedYear }.count
        }

        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectedYear = selectedYear {
            return sections.filter { $0.year == selectedYear }[section].subSection.count
        }

        return sections[section].subSection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(VzrOnOffTripHistoryCell.id)
        cell.selectionStyle = .none
        let sectionsFiltered = selectedYear.map { selectedYear in
            sections.filter { $0.year == selectedYear }
        } ?? sections
        let subSection = sectionsFiltered[indexPath.section].subSection[indexPath.row]
        let title: String
        switch subSection.status {
            case .active:
                title = NSLocalizedString("vzr_on_off_active_trips_title", comment: "")
            case .planned:
                title = NSLocalizedString("vzr_on_off_planned_trips_title", comment: "")
            case .passed:
                title = NSLocalizedString("vzr_on_off_passed_trips_title", comment: "")
        }
        let cellType: VzrOnOffTripHistoryCell.CellType = indexPath.row == 0
            ? .sectionTop(sectionsFiltered[indexPath.section].year)
            : .normal
        cell.configure(title: title, trips: subSection.items, type: cellType)
        return cell
    }
}
