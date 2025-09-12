//
//  ClinicsListViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

// swiftlint:disable line_length file_length
final class ClinicsListViewController: ViewController,
                                       UITableViewDataSource,
                                       UITableViewDelegate,
                                       UISearchBarDelegate {
    struct Input {
        let showMetroDistance: Bool
		var data: () -> NetworkData<ClinicResponse>
        var supportPhone: Phone
    }

    struct Output {
        var clinic: (Clinic) -> Void
        var refresh: () -> Void
        var callSupport: () -> Void
		var tapWebSiteCallback: (URL?) -> Void
		var tapCallCallback: ([Phone]) -> Void
		var tapCell: (Clinic) -> Void
    }

    struct Notify {
        var changed: () -> Void
		var filtered: (SelectClinicFilter?) -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] in
            guard let self,
                  self.isViewLoaded
            else { return }

            self.update()
        },
		filtered: 
		{
			[weak self] selectClinicFilter in
			
			if let selectClinicFilter = selectClinicFilter
			{
				self?.selectClinicFilter = selectClinicFilter
			}
			else
			{
				self?.selectClinicFilter = .init()
			}
			
			self?.filterClinics()
		}
    )
	
	private let stateView = ZeroView()

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!

    private var clinics: [Clinic] = []
	private var filters: [ClinicFilter] = []
	private var selectClinicFilter: SelectClinicFilter = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        update()
    }
	
	private func setupStateView() {
		view.addSubview(stateView)
		
		stateView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			stateView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
			stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
		stateView.isHidden = true
	}

    private func setup() {
        view.backgroundColor = .Background.backgroundContent
        
        title = NSLocalizedString("clinics_picker_title", comment: "")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 190
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.contentInset = .bottom(60)
		
		tableView.registerReusableCell(ClinicTableViewCell.id)

		addZeroView()
		setupStateView()
		searchBar.placeholder = NSLocalizedString("common_search", comment: "")
		searchBar.returnKeyType = .search
		searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .Background.backgroundContent
    }

    private func update() {
        switch input.data() {
            case .loading:
                zeroView?.update(viewModel: .init(kind: .loading))
                showZeroView()
            case .data(let clinicResponse):
                let zeroViewModel = ZeroViewModel(
                    kind: .custom(
                        title: NSLocalizedString("zero_appointment_phone_call", comment: ""),
                        message: String(
                            format: NSLocalizedString("zero_appointment_phone_call_value", comment: ""),
                            input.supportPhone.humanReadable
                        ),
                        iconKind: .none
                    ),
                    buttons: [
                        .init(
                            title: NSLocalizedString("zero_appointment_call", comment: ""),
                            isPrimary: true,
                            action: { [weak self] in self?.output.callSupport() }
                        )
                    ]
                )
                zeroView?.update(viewModel: zeroViewModel)
				clinicResponse.clinicList.isEmpty ? showZeroView() : hideZeroView()
				self.clinics = clinicResponse.clinicList
				self.filters = clinicResponse.filterList
                filterClinics()
                tableView.reloadData()
            case .error(let error):
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.output.refresh() }))
                )
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
        }
        view.endEditing(true)
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		filteredClinics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
	{
		guard let clinic = filteredClinics[safe: indexPath.row]
		else { return UITableViewCell() }
		
		let cell = tableView.dequeueReusableCell(ClinicTableViewCell.id)
		cell.setup(
			clinic: clinic,
			tapWebSiteCallback: output.tapWebSiteCallback,
			tapCallCallback: output.tapCallCallback,
			tapClinicCallback: output.clinic
		)
		
        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
	{
		guard let clinic = filteredClinics[safe: indexPath.row]
		else { return }
		
		self.output.tapCell(clinic)
	}

    // MARK: - Search

	private var filterString: String = ""  {
		didSet {
			filterClinics()
		}
	}
	
    private var filteredClinics: [Clinic] = []

    private func filterClinics()
	{
		let clinics = ClinicAppointmentFlow.getClinicsWithFilter(
			selectClinicFilter: self.selectClinicFilter,
			clinics: self.clinics,
			filters: self.filters
		)
		
        filteredClinics = filterString.isEmpty
            ? clinics
            : clinics.filter {
                ClinicAppointmentFlow.clinicContainsText($0, filterString)
            }
		
		if filteredClinics.isEmpty {
			stateView.isHidden = false
			stateView.update(
				viewModel: .init(
					kind: .custom(
						title: NSLocalizedString("clinic_filter_empty_state_title", comment: ""),
						message: NSLocalizedString("clinic_filter_empty_state_description", comment: ""),
						iconKind: ZeroViewModel.IconKind.custom("search")
					)
				)
			)
		} else {
			stateView.isHidden = true
		}
		
		tableView.reloadData()
    }
	
	// MARK: - UISearchBarDelegate
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		self.searchBar.showsCancelButton = true
	}

	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		searchBar.showsCancelButton = !(searchBar.text?.isEmpty ?? true)
		searchBar.setShowsCancelButton(false, animated: true)
		return true
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		filterString = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = nil
		filterString = ""
		searchBar.showsCancelButton = false
		searchBar.resignFirstResponder()
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if filterString != searchBar.text {
			filterString = searchBar.text ?? ""
		}

		searchBar.resignFirstResponder()
	}
}
