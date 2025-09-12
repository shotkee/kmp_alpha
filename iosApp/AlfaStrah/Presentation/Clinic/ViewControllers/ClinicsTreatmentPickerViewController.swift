//
//  ClinicsTreatmentPickerViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

final class ClinicsTreatmentPickerViewController: ViewController, UITableViewDataSource, UITableViewDelegate
{
    struct TreatmentFilter {
        var isActive: Bool
        let treatment: ClinicTreatment
    }
    struct ServiceHoursFilter {
        var isActive: Bool
        let serviceHoursOption: ClinicServiceHoursOption
    }
    enum FranchiseAvailability: CaseIterable
    {
        case withFranchise
        case withoutFranchise
    }
    struct FranchiseFilter
    {
        let type: FranchiseAvailability
        var isActive: Bool
    }

    struct Input {
        let filters: [TreatmentFilter]
        let serviceHoursFilters: [ServiceHoursFilter]
        let franchiseFilters: [FranchiseFilter]
    }

    struct Output {
        let resetFilters: () -> Void
        let applyFilters: ([TreatmentFilter], [ServiceHoursFilter], [FranchiseFilter]) -> Void
    }

    struct Notify {
        var changed: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] in
            guard let `self` = self, self.isViewLoaded else { return }

            self.updateDisplayedData()
        }
    )

    private enum TableSection: Int, CaseIterable
    {
        case treatment = 0
        case serviceHours = 1
        case franchise = 2
    }
    private static let tableSections = TableSection.allCases

    private let treatmentsSectionHeader = ClinicsFilterSectionHeader()
    private let servicehoursSectionHeader = ClinicsFilterSectionHeader()
    private let franchisesSectionHeader = ClinicsFilterSectionHeader()

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var bottomInsetSizerView: UIView!
    @IBOutlet private var resetFiltersButton: RoundEdgeButton!
    @IBOutlet private var applyFiltersButton: RoundEdgeButton!

    private var treatmentFilters: [TreatmentFilter] = []
    private var serviceHoursFilters: [ServiceHoursFilter] = []
    private var franchiseFilters: [FranchiseFilter] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateDisplayedData()
    }

    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("clinic_picker_filters", comment: "")

        resetFiltersButton <~ Style.RoundedButton.oldOutlinedButtonSmall
        resetFiltersButton.setTitle(
            NSLocalizedString("clinic_picker_reset_all_filters", comment: ""),
            for: .normal
        )

        applyFiltersButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        applyFiltersButton.setTitle(
            NSLocalizedString("clinic_picker_apply_filters", comment: ""),
            for: .normal
        )

		tableView.backgroundColor = .clear
        tableView.contentInset.bottom = bottomInsetSizerView.bounds.height

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()

        treatmentsSectionHeader.set(
            title: NSLocalizedString("info_clinic_treatments", comment: "")
        )
        servicehoursSectionHeader.set(
            title: NSLocalizedString("info_clinic_service_hours", comment: "")
        )
        franchisesSectionHeader.set(
            title: NSLocalizedString("info_clinic_franchise", comment: "")
        )

        addZeroView()
    }

    private func updateDisplayedData() {
        treatmentFilters = input.filters
        serviceHoursFilters = input.serviceHoursFilters
        franchiseFilters = input.franchiseFilters

        zeroView?.update(viewModel: .init(kind: .emptyList))
        treatmentFilters.isEmpty ? showZeroView() : hideZeroView()
        tableView.reloadData()
    }

    private func resetDisplayedFilters() {
        treatmentFilters = treatmentFilters.map {
            var filter = $0
            filter.isActive = false
            return filter
        }
        serviceHoursFilters = serviceHoursFilters.map {
            var filter = $0
            filter.isActive = false
            return filter
        }
        franchiseFilters = franchiseFilters.map {
            var filter = $0
            filter.isActive = false
            return filter
        }

        tableView.reloadData()
    }

    // MARK: - Actions
    @IBAction func resetTap(_ sender: UIButton) {
        resetDisplayedFilters()
    }

    @IBAction func applyTap(_ sender: UIButton) {
        output.applyFilters(treatmentFilters, serviceHoursFilters, franchiseFilters)
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return Self.tableSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Self.tableSections[safe: section] {
            case .treatment:
                return treatmentFilters.count
                
            case .serviceHours:
                return serviceHoursFilters.count
                
            case .franchise:
                return franchiseFilters.count

            case .none:
                return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch Self.tableSections[safe: section] {
            case .treatment:
                return treatmentsSectionHeader
                
            case .serviceHours:
                return servicehoursSectionHeader
                
            case .franchise:
                return franchisesSectionHeader
                
            case .none:
                return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ClinicsTreatmentCell.id, indexPath: indexPath)

        switch Self.tableSections[safe: indexPath.section] {
            case .treatment:
                if let filter = treatmentFilters[safe: indexPath.row] {
                    cell.set(
                        normalIcon: nil,
                        title: filter.treatment.title,
                        isFilterActive: filter.isActive
                    )
                }
                
            case .serviceHours:
                if let filter = serviceHoursFilters[safe: indexPath.row] {
                    cell.set(
                        normalIcon: nil,
                        title: filter.serviceHoursOption.title,
                        isFilterActive: filter.isActive
                    )
                }

            case .franchise:
                if let franchiseFilter = franchiseFilters[safe: indexPath.row] {
                    switch franchiseFilter.type {
                        case .withFranchise:
                            cell.set(
								normalIcon: .Icons.pinPercent
									.tintedImage(withColor: .Icons.iconSecondary)
									.overlay(with: .Icons.pin.tintedImage(withColor: .Icons.iconContrast)),
                                title: NSLocalizedString("filter_clinics_with_franchise", comment: ""),
                                isFilterActive: franchiseFilter.isActive
                            )
                        case .withoutFranchise:
                            cell.set(
								normalIcon: .Icons.pinAlfa
									.tintedImage(withColor: .Icons.iconAccent)
									.overlay(with: .Icons.pin.tintedImage(withColor: .Icons.iconContrast)),
                                title: NSLocalizedString("filter_clinics_without_franchise", comment: ""),
                                isFilterActive: franchiseFilter.isActive
                            )
                    }
                }

            case .none:
                break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Self.tableSections[safe: indexPath.section] {
            case .treatment:
                treatmentFilters[indexPath.row].isActive.toggle()
                
            case .serviceHours:
                serviceHoursFilters[indexPath.row].isActive.toggle()
                
            case .franchise:
                franchiseFilters[indexPath.row].isActive.toggle()

            case .none:
                break
        }
        UIView.performWithoutAnimation {
            tableView.reloadRows(at: [ indexPath ], with: .automatic)
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		tableView.reloadData()
	}
}
