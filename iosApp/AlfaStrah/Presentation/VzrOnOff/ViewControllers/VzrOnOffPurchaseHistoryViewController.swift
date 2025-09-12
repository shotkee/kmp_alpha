//
//  VzrOnOffPurchaseHistoryViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/17/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class VzrOnOffPurchaseHistoryViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    private enum Constants {
        static let filterViewHeight: CGFloat = 84
        static let defaultOffset: CGFloat = 18
    }

    private struct Section {
        let year: Int
        let items: [VzrOnOffPurchaseHistoryItem]
    }

    struct Input {
        let history: (@escaping (Result<[VzrOnOffPurchaseHistoryItem], AlfastrahError>) -> Void) -> Void
    }

    struct Output {
        let showFilters: ([Int], @escaping (Int) -> Void) -> Void
        let buyPackages: () -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var filterImageView: UIImageView!
    @IBOutlet private var filterLabel: UILabel!
    @IBOutlet private var filterDiscardButton: UIButton!
    @IBOutlet private var filterContainerView: UIView!
    @IBOutlet private var gradientView: UIView!
    @IBOutlet private var buyButton: RoundEdgeButton!
    private var gradientLayer: CAGradientLayer?
    private var sections: [Section] = []
    private var selectedYear: Int? {
        didSet {
            tableView.reloadData()
            updateFilterState(selectedYear: selectedYear)
        }
    }
    private var filteredSections: [Section] {
        selectedYear.map { year in
            sections.filter { $0.year == year }
        } ?? sections
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
        title = NSLocalizedString("vzr_purchase_history_title", comment: "")
        tableView.registerReusableCell(VzrOnOffPurchaseHistoryCell.id)
        tableView.separatorStyle = .none
        buyButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        buyButton.setTitle(NSLocalizedString("vzr_buy_day_packages_button_title", comment: ""), for: .normal)
        filterImageView.image = UIImage(named: "ic-filter")
        filterLabel <~ Style.Label.primaryText
        filterDiscardButton.setTitle(NSLocalizedString("common_reset_action", comment: ""), for: .normal)
        filterDiscardButton.setTitleColor(Style.Color.Palette.darkGray, for: .normal)
		filterDiscardButton.titleLabel?.font = Style.Font.buttonSmall
        updateFilterState(selectedYear: selectedYear)
        filterDiscardButton.isHidden = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor ]
        gradientView.layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
        addZeroView()
        refreshHistory()
    }

    private func updateFilterState(selectedYear: Int?) {
        if let selectedYear = selectedYear {
            filterLabel.text = String(format: NSLocalizedString("vzr_purchase_filter_text", comment: ""), "\(selectedYear)")
            filterDiscardButton.isHidden = false
        } else {
            filterLabel.text = NSLocalizedString("vzr_filter_all_purchases", comment: "")
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
                        kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.refreshHistory() }))
                    )
                    self.zeroView?.update(viewModel: zeroViewModel)
            }
        }
    }

    private func updateHistoryViewStruct(_ history: [VzrOnOffPurchaseHistoryItem]) {
        guard !history.isEmpty else { return }

        sections = []
        var years: Set<Int> = []
        history.forEach { years.insert($0.year) }
        for year in years.sorted() {
            sections.append(.init(year: year, items: history.filter { $0.year == year }))
        }
        tableView.reloadData()
        let shouldHideFilter = years.count <= 1
        filterContainerView.isHidden = shouldHideFilter
        tableView.contentInset.top = shouldHideFilter ? 0 : filterContainerView.frame.height
    }

    @IBAction private func filterTap(_ sender: UIButton) {
        output.showFilters(sections.map { $0.year }) { [weak self] year in
            self?.selectedYear = year
        }
    }

    @IBAction func discardTap(_ sender: UIButton) {
        selectedYear = nil
    }

    @IBAction private func buyTap(_ sender: UIButton) {
        output.buyPackages()
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: VzrOnOffPurchaseHistoryHeaderView = .fromNib()
        headerView.set(year: filteredSections[section].year)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        filteredSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredSections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(VzrOnOffPurchaseHistoryCell.id)
        let item = filteredSections[indexPath.section].items[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(date: item.purchaseDate, title: item.title, price: item.currencyPrice, currencyCode: item.currency)
        return cell
    }
}
