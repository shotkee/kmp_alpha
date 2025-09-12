//
//  FilterInsuranceViewController.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 02/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class FilterInsuranceViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var filterButton: RoundEdgeButton!
    private var allFilters: [InsuranceCategoryMain.CategoryType] = [ .auto, .health, .property, .travel, .passengers ]
    private var selectedFilters: Set<InsuranceCategoryMain.CategoryType> = Set() {
        didSet {
            updateButtonTitle()
        }
    }
    var input: Input!
    var output: Output!

    struct Input {
        var insurances: [InsuranceGroupCategory]
        var selected: [InsuranceCategoryMain.CategoryType]
    }

    struct Output {
        var filteredInsurances: ([InsuranceCategoryMain.CategoryType]) -> Void
    }

    @IBAction private func toFilterTap(_ sender: Any) {
        let array = selectedFilters.count == allFilters.count ? [] : Array(selectedFilters)
        output.filteredInsurances(array)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
		
        selectedFilters = Set(input.selected)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.contentInset.top = 9
        updateButtonTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
    }

    private func updateButtonTitle() {
        let fiteredCategorys = input.insurances.filter { selectedFilters.contains($0.insuranceCategory.type) }
        let filteredInsurances = fiteredCategorys.flatMap { $0.insuranceList }
        let format = NSLocalizedString("insurance_filter_count", comment: "")
        let insuranceCount = String.localizedStringWithFormat(format, filteredInsurances.count)
        let filterFormat = NSLocalizedString("filter_insurance", comment: "")
        let title = filteredInsurances.isEmpty ? insuranceCount : String.localizedStringWithFormat(filterFormat, insuranceCount)
		filterButton <~ Style.RoundedButton.redBackground
		filterButton.setTitle(title, for: .normal)
        filterButton.isEnabled = !filteredInsurances.isEmpty
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(FilterTableViewCell.id)
        let filter = allFilters[indexPath.row]
        let showSeporator = indexPath.row == (allFilters.count - 1)
        cell.confugure(title: filter.title, showSeporator: !showSeporator)
        if selectedFilters.contains(filter) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            change(selection: true, for: cell)
        } else {
            change(selection: false, for: cell)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allFilters.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let filter = allFilters[indexPath.row]
        change(selection: false, for: tableView.cellForRow(at: indexPath))
        selectedFilters.remove(filter)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = allFilters[indexPath.row]
        change(selection: true, for: tableView.cellForRow(at: indexPath))
        selectedFilters.insert(filter)
    }

    private func change(selection: Bool, for cell: UITableViewCell?) {
        (cell as? FilterTableViewCell)?.toggleSelection(selection)
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
