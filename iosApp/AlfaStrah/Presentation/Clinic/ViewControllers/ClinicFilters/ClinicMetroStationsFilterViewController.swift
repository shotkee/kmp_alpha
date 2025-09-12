//
//  ClinicMetroStationsFilterViewController.swift
//  AlfaStrah
//
//  Created by Makson on 15.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints
import Legacy

class ClinicMetroStationsFilterViewController: ViewController
{
	enum TableHeader
	{
		case town
		case search([MetroStation])
		case station([MetroStation])
		case empty
	}
	
	// MARK: - Outlets
	private var tableView = createTableView()
	private var applyButton = RoundEdgeButton()
	
	// MARK: - Variable
	private var headers: [TableHeader] = []
	private var selectedMetroStations: [MetroStation] = []
	private var metroStations: [MetroStation] = []
	private var filterMetroStations: [MetroStation] = []
	private var isReset: Bool = false
	private var isNewCity: Bool = false
	
	private var searchText: String = ""
	{
		didSet
		{
			self.searchFilterWithText(text: searchText)
		}
	}
	
	// MARK: - Input
	
	struct Input
	{
		let cacheCityId: Int?
		let cacheMetroStation: [MetroStation]
		var clinicMetro: ClinicWithMetro
	}
	
	var input: Input!

	// MARK: - Output
	
	struct Output
	{
		let updateCity: (Int) -> Void
		let apply: ((cityId: Int?, cityName: String?, metroStation: [MetroStation])) -> Void
	}
	
	var output: Output!
	
	// MARK: - Notify
	
	struct Notify {
		let update: (_ clinicWithMetro: ClinicWithMetro) -> Void
	}
	
	private(set) lazy var notify = Notify(
		update: { [weak self] clinicWithMetro in
			guard let self = self
			else { return }
			
			self.isNewCity = self.input.clinicMetro.id != clinicWithMetro.id
			self.input.clinicMetro = clinicWithMetro
			metroStations = clinicWithMetro.metroStationList
			filterMetroStations = metroStations
			selectedMetroStations = []
			setupTableHeaders()
			self.updateStateApplyButton()
			self.updateVisibleRightButton()
			self.tableView.reloadData()
		}
	)
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		metroStations = input.clinicMetro.metroStationList
		filterMetroStations = metroStations
		setupUI()
    }
}

private extension ClinicMetroStationsFilterViewController
{
	static func createTableView() -> UITableView
	{
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.rowHeight = UITableView.automaticDimension
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		tableView.sectionIndexColor = .Text.textAccentThemed
		tableView.registerReusableCell(ClinicFiltersViewTableViewCell.id)
		tableView.registerReusableCell(ClinicFiltersCheckboxTableViewCell.id)
		tableView.registerReusableCell(ClinicMetroStationsSearchTableViewCell.id)
		tableView.registerReusableCell(ClinicEmptyStateTableViewCell.id)
		tableView.keyboardDismissMode = .onDrag
		
		return tableView
	}
	
	func setupUI()
	{
		self.title = NSLocalizedString("clinic_filter_metro_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
		setSelectionStation()
		setupTableView()
		setupTableHeaders()
		setupApplyButton()
		updateStateApplyButton()
		updateVisibleRightButton()
	}
	
	func setSelectionStation()
	{
		if let cityId = input.cacheCityId,
		   cityId == input.clinicMetro.id
		{
			input.cacheMetroStation.forEach {
				insertOrDeleteSelectMetroStation(metroStation: $0)
			}
		}
	}
	
	func updateVisibleRightButton()
	{
		if selectedMetroStations.isEmpty
		{
			self.navigationItem.rightBarButtonItem = nil
		}
		else
		{
			addRightButton(
				title: NSLocalizedString("common_reset_action", comment: ""),
				action:
			 {
				 [weak self] in
				 self?.isReset = true
				 self?.removeAllMetroStation()
			 }
			)
		}
	}
	
	func setupTableView()
	{
		view.addSubview(tableView)
		tableView.edgesToSuperview()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.contentInset.bottom = 63
		tableView.rowHeight = UITableView.automaticDimension
		tableView.allowsMultipleSelection = true
	}
	
	func removeAllMetroStation()
	{
		self.selectedMetroStations = []
		setupTableHeaders()
		updateStateApplyButton(isReset: true)
		updateVisibleRightButton()
	}
	
	func setupTableHeaders()
	{
		headers = [
			.town,
			.search(selectedMetroStations)
		]
		addStationOrEmptyStateSections()
		
		self.tableView.reloadData()
	}
	
	func addStationOrEmptyStateSections()
	{
		func getStation(title: String) -> TableHeader
		{
			let stations = filterMetroStations
				.filter
			{
				if let firstSymbol = $0.title.first
				{
					return String(firstSymbol) == title
				}
				
				return false
			}
			
			return .station(stations)
		}
		
		if filterMetroStations.isEmpty
		{
			headers.append(
				.empty
			)
		}
		else
		{
			getStationSection().forEach
			{
				stationTitle in
				
				let stations = getStation(title: stationTitle)
				
				headers.append(
					stations
				)
			}
		}
	}
	
	func getStationSection() -> [String]
	{
		filterMetroStations.compactMap { $0.title.first?.uppercased() }.uniqued()
	}
	
	func setupApplyButton()
	{
		view.addSubview(applyButton)
		applyButton.setTitle(
			NSLocalizedString(
				"clinic_filter_apply_title_button",
				comment: ""
			),
			for: .normal
		)
		applyButton <~ Style.RoundedButton.primaryButtonLarge
		applyButton.addTarget(self, action: #selector(onApplyButton), for: .touchUpInside)
		applyButton.edgesToSuperview(
			excluding: .top,
			insets: .init(
				top: 0,
				left: 15,
				bottom: 15,
				right: 15
			),
			usingSafeArea: true
		)
		applyButton.height(48)
	}
	
	@objc func onApplyButton()
	{
		if isReset
		{
			output.apply(
				(cityId: nil, cityName: nil, metroStation: self.selectedMetroStations)
			)
		}
		else
		{
			output.apply(
				(cityId: input.clinicMetro.id, cityName: input.clinicMetro.title, metroStation: self.selectedMetroStations)
			)
		}
	}
	
	private func insertOrDeleteSelectMetroStation(metroStation: MetroStation)
	{
		self.isReset = false
		var updateSelectedMetroStations = selectedMetroStations
		var hasDeletedItem: Bool = false
		
		for (index, station) in updateSelectedMetroStations.enumerated()
		{
			if station.id == metroStation.id
			{
				updateSelectedMetroStations.remove(at: index)
				hasDeletedItem = true
			}
		}
		
		if !hasDeletedItem
		{
			updateSelectedMetroStations.append(metroStation)
		}
		
		self.selectedMetroStations = updateSelectedMetroStations
		self.setupTableHeaders()
		self.updateStateApplyButton()
		self.updateVisibleRightButton()
	}
	
	private func updateStateApplyButton(isReset: Bool = false)
	{
		if !input.cacheMetroStation.isEmpty,
		   !selectedMetroStations.isEmpty
		{
			var isEnabled = false
			if input.cacheMetroStation.count != selectedMetroStations.count
			{
				isEnabled = true
			}
			else
			{
				selectedMetroStations.forEach
				{
					selectedMetro in
					
					if !input.cacheMetroStation.contains(where: { $0.id == selectedMetro.id })
					{
						isEnabled = true
					}
				}
			}
			
			applyButton.isEnabled = isEnabled
		}
		else if isReset && !input.cacheMetroStation.isEmpty && !isNewCity
		{
			applyButton.isEnabled = true
		}
		else
		{
			applyButton.isEnabled = !selectedMetroStations.isEmpty
		}
	}
	
	private func searchFilterWithText(text: String)
	{
		if text.isEmpty
		{
			self.filterMetroStations = metroStations
		}
		else
		{
			self.filterMetroStations = metroStations.filter { $0.title.lowercased().contains(text.lowercased()) }
		}
		self.filterTableView()
		self.updateStateApplyButton()
		self.updateVisibleRightButton()
	}
	
	private func filterTableView()
	{
		guard headers.count >= 3
		else { return }
		
		UIView.setAnimationsEnabled(false)
		var indexPaths: [Int] = (2 ..< headers.count).map { $0 }
		headers = [
			.town,
			.search(selectedMetroStations)
		]
		self.tableView.beginUpdates()
		for index in indexPaths
		{
			tableView.deleteSections([index], with: .fade)
		}
		self.tableView.endUpdates()

		addStationOrEmptyStateSections()
		indexPaths = (2 ..< headers.count).map { $0 }
		self.tableView.beginUpdates()
		for index in indexPaths
		{
			tableView.insertSections([index], with: .fade)
		}
		self.tableView.endUpdates()
		
		UIView.setAnimationsEnabled(true)
	}
}

extension ClinicMetroStationsFilterViewController: UITableViewDataSource, UITableViewDelegate
{
	func numberOfSections(in tableView: UITableView) -> Int 
	{
		headers.count
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? 
	{
		guard let header = headers[safe: section]
		else { return nil }
		
		switch header
		{
			case .town:
				return createTownHeaderView(
					icon: .Icons.train,
					title: NSLocalizedString(
						"clinic_filter_metro_title",
						comment: ""
					)
				)
			
			case .search, .empty:
				return nil
			
			case .station(let stations):
				guard let firstStation = stations.first
				else { return nil }
			
				return createHeaderView(title: firstStation.title.firstLetter())
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch headers[section]
		{
			case .town, 
				 .search,
				 .empty:
			
				return 1
			
			case .station(let array):
				return array.count
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat 
	{
		guard let header = headers[safe: section]
		else { return CGFloat.leastNonzeroMagnitude }
		
		switch header
		{
			case .town:
				return 44
			
			case .search, .empty:
				return CGFloat.leastNonzeroMagnitude
			
			case .station:
				return 52
		}
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat 
	{
		CGFloat.leastNonzeroMagnitude
	}
	
	func sectionIndexTitles(for tableView: UITableView) -> [String]? 
	{
		getStationSection()
	}
	
	func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int 
	{
		tableView.scrollToRow(
			at: IndexPath(row: 0, section: index),
			at: .top,
			animated: true
		)
		
		return index
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		guard let header = headers[safe: indexPath.section]
		else { return UITableViewCell() }
		
		switch header
		{
			case .town:
				return createClinicFiltersViewTableViewCell()
			
			case .empty:
				return createClinicEmptyStateTableViewCell()
			
			case .search(let metroStations):
				return createClinicMetroStationsSearchTableViewCell(
					metroStations: metroStations
				)
			
			case .station(let stations):
				return createClinicFiltersCheckboxTableViewCell(
					indexPath: indexPath, 
					metroStations: stations
				)
		}
	}
	
	private func createClinicEmptyStateTableViewCell() -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(ClinicEmptyStateTableViewCell.id)
		
		return cell
	}
	
	private func createClinicMetroStationsSearchTableViewCell(
		metroStations: [MetroStation]
	) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(ClinicMetroStationsSearchTableViewCell.id)
		cell.setup(
			metroStations: metroStations,
			tapDeleteMetroStationCallback: 
		  {
				[weak self] metroStation in
			  
				self?.insertOrDeleteSelectMetroStation(metroStation: metroStation)
		  },
			editTextCallback: 
		  {
			  [weak self] text in
				
			  self?.searchText = text
		  }
		)
		
		return cell
	}
	
	private func createClinicFiltersViewTableViewCell() -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(ClinicFiltersViewTableViewCell.id)
		cell.setup(
			typeData: .title(
				String.localizedStringWithFormat(
					NSLocalizedString("clinic_filter_city_metro_title", comment: ""),
					input.clinicMetro.title
				)
			),
			hasMetroStationList: true
		)
		
		return cell
	}
	
	private func createClinicFiltersCheckboxTableViewCell(
		indexPath: IndexPath,
		metroStations: [MetroStation]
	) -> UITableViewCell
	{
		guard let metroStation = metroStations[safe: indexPath.row]
		else { return UITableViewCell() }
		
		let cell = tableView.dequeueReusableCell(ClinicFiltersCheckboxTableViewCell.id)
		
		cell.setup(
			typeData: .metro(
				metroStation
			),
			isSelected: selectedMetroStations.contains(where: { $0.id == metroStation.id })
		)
		
		cell.tapSelectedCallback =
		{
			[weak self] in
			   
			guard let self,
				  let station = metroStations[safe: indexPath.row]
			else { return }
		   
			insertOrDeleteSelectMetroStation(
				metroStation: station
			)
		}
		
		return cell
	}
	
	private func createTownHeaderView(
		icon: UIImage,
		title: String
	) -> UIView
	{
		let view = UIView()
		view.backgroundColor = .Background.backgroundContent
		
		let containerView = UIView()
		containerView.backgroundColor = .clear
		view.addSubview(containerView)
		containerView.edgesToSuperview(
			insets: .init(
				top: 24,
				left: 18,
				bottom: 0,
				right: 18
			))
		
		let imageView = UIImageView()
		imageView.image = icon.resized(newWidth: 20)?
			.tintedImage(withColor: .Icons.iconPrimary)
		containerView.addSubview(imageView)
		imageView.size(
			.init(width: 20, height: 20)
		)
		imageView.verticalToSuperview()
		imageView.leadingToSuperview()
		
		let label = UILabel()
		label <~ Style.Label.primaryHeadline1
		label.numberOfLines = 1
		label.text = title
		containerView.addSubview(label)
		label.verticalToSuperview()
		label.leadingToTrailing(of: imageView, offset: 5)
		
		return view
	}
	
	private func createHeaderView(title: String) -> UIView
	{
		let view = UIView()
		view.backgroundColor = .clear
		
		let titleLabel = UILabel()
		titleLabel <~ Style.Label.secondaryHeadline1
		titleLabel.numberOfLines = 1
		titleLabel.text = title
		view.addSubview(titleLabel)
		titleLabel.verticalToSuperview(
			insets: .vertical(16)
		)
		titleLabel.leadingToSuperview(offset: 18)
		
		let separatorView = UIView()
		separatorView.height(1)
		separatorView.backgroundColor = .Stroke.divider
		view.addSubview(separatorView)
		separatorView.bottomToSuperview()
		separatorView.leadingToSuperview(
			offset: 18
		)
		separatorView.trailingToSuperview(offset: 22)
		
		return view
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
	{
		guard let header = headers[safe: indexPath.section]
		else { return }
		
		switch header
		{
			case .town:
				self.output.updateCity(input.clinicMetro.id)
			
			case .search,
				 .empty,
				 .station:
				break
		}
	}
}

// MARK: - Dark Theme Support

extension ClinicMetroStationsFilterViewController
{
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
	{
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
