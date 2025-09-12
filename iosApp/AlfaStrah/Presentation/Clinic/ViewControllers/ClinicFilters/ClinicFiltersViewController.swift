//
//  ClinicFiltersViewController.swift
//  AlfaStrah
//
//  Created by Makson on 10.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

// swiftlint:disable line_length file_length
class ClinicFiltersViewController: ViewController {
	// MARK: - Outlets
	private var tableView = createTableView()
	private var applyButton = RoundEdgeButton()
	
	private var selectClinicFilter: SelectClinicFilter = .init()
	
	// MARK: - Input
	
	struct Input 
	{
		let cacheClinicFilter: SelectClinicFilter
		let cityList: [ClinicWithMetro]
		let filterList: [ClinicFilter]
	}
	
	var input: Input!

	// MARK: - Output
	
	struct Output
	{
		let onMetroTap: ([ClinicWithMetro]) -> Void
		let onSpecialityTap: (ClinicFilter) -> Void
		let onInformationTap: (String, [ClinicFilterInformation]) -> Void
		let onResetFilter: () -> Void
		let onApplyFilter: (SelectClinicFilter?) -> Void
	}
	
	var output: Output!
	
	// MARK: - Notify
	
	struct Notify {
		let updateCityAndMetroFilter: (_ selectCityId: Int?, _ selectCityName: String?, _ selectMetroStations: [MetroStation]) -> Void
		let updateSpecialties: (_ specialties: [String]) -> Void
	}
	
	private(set) lazy var notify = Notify(
		updateCityAndMetroFilter: { [weak self] selectCityId, selectCityName, selectMetroStations  in
			guard let self = self
			else { return }
			
			self.updateCityAndMetroFilter(
				selectCityId: selectCityId,
				selectCityName: selectCityName,
				selectMetroStations: selectMetroStations
			)
		},
		updateSpecialties: { [weak self] specialties in
			guard let self = self
			else { return }

			self.updateFilters(title: "специальности", newFilters: specialties)
		}
	)

    override func viewDidLoad()
	{
		super.viewDidLoad()

		buildUI()
    }
}

private extension ClinicFiltersViewController
{
	static func createTableView() -> UITableView
	{
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.registerReusableCell(ClinicFiltersCheckboxTableViewCell.id)
		tableView.registerReusableCell(ClinicFiltersViewTableViewCell.id)
		tableView.rowHeight = UITableView.automaticDimension
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		tableView.allowsMultipleSelection = true
		
		return tableView
	}
	
	func buildUI()
	{
		self.selectClinicFilter = input.cacheClinicFilter
		title = NSLocalizedString("clinic_filter_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
		setupTableView()
		setupApplyButton()
		applyButton.isEnabled = false
		updateVisibleRightButton()
	}
	
	func updateVisibleApplyButton(isNotEqualFilters: Bool)
	{
		applyButton.isEnabled = isNotEqualFilters
	}
	
	func hasAnyFilter() -> Bool
	{
		let hasMetroFilters = selectClinicFilter.selectCityId != nil 
			&& selectClinicFilter.selectCityName != nil
			&& !selectClinicFilter.selectMetroStations.isEmpty
		
		return hasMetroFilters
			|| !selectClinicFilter.selectedFilters.isEmpty
	}
	
	func setupTableView()
	{
		view.addSubview(tableView)
		tableView.edgesToSuperview()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.contentInset.bottom = 63
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
	
	func updateVisibleRightButton()
	{
		if selectClinicFilter.isEmpty
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
				 
				 self?.selectClinicFilter = .init()
				 self?.output.onResetFilter()
				 self?.update(isNotEqualFilters: false)
			 }
			)
		}
	}
	
	@objc func onApplyButton()
	{
		self.output.onApplyFilter(selectClinicFilter)
	}
	
	private func updateCityAndMetroFilter(
		selectCityId: Int?,
		selectCityName: String?,
		selectMetroStations: [MetroStation]
	)
	{
		let isNotEqual = isNotEqualMetroFilter(
			selectCityId: selectCityId,
			selectMetroStations: selectMetroStations
		)
		selectClinicFilter.selectCityId = selectCityId
		selectClinicFilter.selectCityName = selectCityName
		selectClinicFilter.selectMetroStations = selectMetroStations
		
		let isNotEqualWithCacheData = isNotEqualMetroFilter(
			selectCityId: input.cacheClinicFilter.selectCityId,
			selectMetroStations: input.cacheClinicFilter.selectMetroStations
		)
		
		update(isNotEqualFilters: isNotEqual && isNotEqualWithCacheData)
	}
	
	private func updateFilters(title: String, newFilters: [String])
	{
		let isNotEqualFilters = isNotEqualFilters(
			cacheFilters: input.cacheClinicFilter.selectedFilters[title] ?? [],
			newFilters: newFilters
		)
		selectClinicFilter.selectedFilters[title] = newFilters.isEmpty
			? nil
			: newFilters
		update(isNotEqualFilters: isNotEqualFilters)
	}
	
	private func update(isNotEqualFilters: Bool)
	{
		if isNotEqualFilters
		{
			self.updateVisibleApplyButton(
				isNotEqualFilters: isNotEqualFilters
			)
		}
		else if !input.cacheClinicFilter.isEmpty
		{
			let isNotMetroFilterEqual = isNotEqualMetroFilter(
				selectCityId: input.cacheClinicFilter.selectCityId,
				selectMetroStations: input.cacheClinicFilter.selectMetroStations
			)
			
			let keys = input.cacheClinicFilter.selectedFilters.keys
			var isNotFilterEqual = false
			
			keys.forEach
			{
				key in
				
				if let cacheClinicFilterValue = input.cacheClinicFilter.selectedFilters[key],
				   self.isNotEqualFilters(
					cacheFilters: cacheClinicFilterValue,
					newFilters: selectClinicFilter.selectedFilters[key] ?? []
				   )
				{
					isNotFilterEqual = true
				}
			}
			
			let isNotEqualFilters = isNotMetroFilterEqual
				|| isNotFilterEqual
			
			self.updateVisibleApplyButton(
				isNotEqualFilters: isNotEqualFilters
			)
		}
		else
		{
			self.updateVisibleApplyButton(
				isNotEqualFilters: hasAnyFilter()
			)
		}
		
		updateVisibleRightButton()
		
		self.tableView.reloadData()
	}
	
	private func isNotEqualMetroFilter(
		selectCityId: Int?,
		selectMetroStations: [MetroStation]
	) -> Bool
	{
		if (selectClinicFilter.selectCityId != selectCityId) || selectClinicFilter.selectMetroStations.count != selectMetroStations.count
		{
			return true
		}
		else
		{
			var isNotEqual = false
			
			selectClinicFilter.selectMetroStations.forEach
			{
				cacheMetroStation in
				
				if !selectMetroStations.contains(where: { $0.id == cacheMetroStation.id})
				{
					isNotEqual = true
					return
				}
			}
			
			return isNotEqual
		}
	}
	
	private func isNotEqualFilters(
		cacheFilters: [String],
		newFilters: [String]
	) -> Bool
	{
		if cacheFilters.isEmpty,
		   newFilters.isEmpty
		{
			return false
		}
		else if cacheFilters.count != newFilters.count
		{
			return true
		}
		else
		{
			var isNotEqual = false
			
			cacheFilters.forEach
			{
				cacheFilter in
				
				if !newFilters.contains(where: { $0 == cacheFilter})
				{
					isNotEqual = true
					return
				}
			}
			
			return isNotEqual
		}
	}
}

extension ClinicFiltersViewController: UITableViewDataSource, UITableViewDelegate
{
	func numberOfSections(in tableView: UITableView) -> Int
	{
		1 + input.filterList.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if section == 0
		{
			return 1
		}
		else
		{
			guard let filter = input.filterList[safe: section - 1]
			else { return 0 }
			
			switch filter.renderType
			{
				case .checkbox:
					return filter.values.count
				
				case .specialities:
					return 1
			}
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? 
	{
		if section == 0
		{
			return createHeaderView(
				icon: .Icons.train,
				title: NSLocalizedString(
					"clinic_filter_metro_title",
					comment: ""
				),
				index: section
			)
		}
		else
		{
			guard let filter = input.filterList[safe: section - 1]
			else { return nil }
			
			return createHeaderView(
				url: filter.icon.url(for: traitCollection.userInterfaceStyle),
				title: filter.title,
				index: section
			)
		}
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? 
	{
		if section == 0
		{
			return createFooterView()
		}
		else
		{
			return input.filterList.count != section
				? createFooterView()
				: nil
		}
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat 
	{
		if section == 0
		{
			return 25
		}
		else
		{
			return input.filterList.count != section
				? 25
				: .leastNonzeroMagnitude
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
	{
		56
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		if indexPath.section == 0
		{
			return createClinicFiltersViewTableViewCell(
				typeData: .view(selectClinicFilter.selectMetroStations),
				isMetroCell: true
			)
		}
		else
		{
			let filterList = input.filterList
			
			guard let filter = filterList[safe: indexPath.section - 1],
				  let value = filter.values[safe: indexPath.row]
			else { return UITableViewCell() }
			
			switch filter.renderType
			{
				case .checkbox:
					return createClinicFiltersCheckboxTableViewCell(
						headerTitle: filter.title.lowercased(),
						valueTitle: value,
						indexPath: indexPath
					)
				
				case .specialities:
					return createClinicFiltersViewTableViewCell(
						typeData: .title(getTitleForSpeciality()),
						isMetroCell: false
					)
			}
		}
	}
	
	
	private func getTitleForSpeciality() -> String
	{
		guard let specialities = selectClinicFilter.selectedFilters["специальности"],
			!specialities.isEmpty
		else
		{
			return NSLocalizedString(
				"clinic_filter_city_specialities_title",
				comment: ""
			)
		}
		
		let specialitiesToString = specialities.joined(separator: ", ")
		let widthSpecialities = specialitiesToString.width(
			withConstrainedHeight: 15,
			font: Style.Font.text
		)
		
		let maxWidthLabel = UIScreen.main.bounds.width - 96
		
		if widthSpecialities > maxWidthLabel
		{
			let localized = NSLocalizedString(
				"count_specialties",
				comment: ""
			)
			
			let specialitiesString = String(
				format: localized,
				locale: .init(identifier: "ru"),
				specialities.count
			)
			
			return specialitiesString
		}
		else
		{
			return specialitiesToString
		}
	}
	
	private func createClinicFiltersCheckboxTableViewCell(
		headerTitle: String,
		valueTitle: String,
		indexPath: IndexPath
	) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(ClinicFiltersCheckboxTableViewCell.id)
		cell.setup(
			typeData: .usual(valueTitle),
			isSelected: isSelectedFilter(headerTitle: headerTitle, valueTitle: valueTitle)
		)
		
		cell.tapSelectedCallback =
		{
			[weak self] in
				
			guard let self,
				  let filter = self.input.filterList[safe: indexPath.section - 1]
			else { return }
				
			updateFilters(
				title: filter.title.lowercased(),
				newFilters: updateFilter(
					values: selectClinicFilter.selectedFilters[filter.title.lowercased()] ?? [],
					newValue: filter.values[indexPath.row]
				)
			)
		}
		
		return cell
	}
	
	private func isSelectedFilter(
		headerTitle: String,
		valueTitle: String
	) -> Bool
	{
		guard let filterArray = selectClinicFilter.selectedFilters[headerTitle.lowercased()]
		else { return false }
		
		return filterArray.contains(where: { $0 == valueTitle })
	}
	
	private func createClinicFiltersViewTableViewCell(
		typeData: ClinicFiltersViewTableViewCell.TypeData,
		isMetroCell: Bool
	) -> UITableViewCell
	{
		
		let cell = tableView.dequeueReusableCell(ClinicFiltersViewTableViewCell.id)
		cell.setup(
			typeData: typeData,
			hasMetroStationList: false
		)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
	{
		if indexPath.section == 0
		{
			self.output.onMetroTap(input.cityList)
		}
		else
		{
			guard let filter = input.filterList[safe: indexPath.section - 1]
			else { return }
			
			if filter.title.lowercased() == "специальности"
			{
				self.output.onSpecialityTap(filter)
			}
		}
	}
	
	func updateFilter(values: [String], newValue: String) -> [String]
	{
		var newValues = values
		
		if !newValues.isEmpty
		{
			if newValues.contains(where: { $0 == newValue })
			{
				newValues = newValues.filter { $0 != newValue }
			}
			else
			{
				newValues.append(newValue)
			}
		}
		else
		{
			newValues.append(newValue)
		}
		
		return newValues
	}
	
	private func createFooterView() -> UIView
	{
		let view = UIView()
		view.backgroundColor = .clear
		
		let separatorView = UIView()
		separatorView.backgroundColor = .Stroke.divider
		separatorView.height(1)
		
		view.addSubview(separatorView)
		separatorView.horizontalToSuperview(
			insets: .horizontal(18)
		)
		separatorView.bottomToSuperview()
		separatorView.topToSuperview(offset: 24)
		
		
		return view
	}
	
	private func createHeaderView(
		icon: UIImage? = nil,
		url: URL? = nil,
		title: String,
		index: Int
	) -> UIView
	{
		let view = UIView()
		view.backgroundColor = .clear
		
		let containerView = UIView()
		containerView.backgroundColor = .clear
		view.addSubview(containerView)
		containerView.edgesToSuperview(
			insets: .init(
				top: 24,
				left: 18,
				bottom: 12,
				right: 18
			)
		)
		
		let imageView = UIImageView()
		if let url = url
		{
			imageView.sd_setImage(with: url)
		}
		else
		{
			imageView.image = icon?
				.resized(newWidth: 20)?
				.tintedImage(withColor: .Icons.iconPrimary)
		}
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
				
		
		let infoButton = UIButton(type: .system)
		infoButton.tintColor = UIColor.Icons.iconTertiary
		infoButton.setImage(
			.Icons.info,
			for: .normal
		)
		containerView.addSubview(infoButton)
		infoButton.centerYToSuperview()
		infoButton.trailingToSuperview()
		infoButton.leadingToTrailing(of: label)
		infoButton.tag = index
		infoButton.height(20)
		infoButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
		infoButton.widthToHeight(of: infoButton)
		infoButton.addTarget(
			self,
			action: #selector(onTap),
			for: .touchUpInside
		)
		
		return view
	}
	
	@objc private func onTap(sender: UIButton)
	{
		if sender.tag == 0
		{
			self.output.onInformationTap(
				NSLocalizedString(
					"clinic_filter_metro_title",
					comment: ""
				),
				[
					.init(
						title: "",
						description: NSLocalizedString(
							"clinic_filter_metro_description",
							comment: ""
						)
					)
				]
			)
		}
		else if let filter = input.filterList[safe: sender.tag - 1]
		{
			self.output.onInformationTap(filter.title, filter.information)
		}
	}
}

// MARK: - Dark Theme Support

extension ClinicFiltersViewController
{
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) 
	{
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
