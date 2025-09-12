//
//  ClinicTownOrSpecialtyFilterViewController.swift
//  AlfaStrah
//
//  Created by Makson on 14.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class ClinicTownOrSpecialtyFilterViewController: ViewController
{
	enum TypeData
	{
		case citiesList([ClinicWithMetro])
		case specialty(ClinicFilter)
	}
	
	enum CacheData
	{
		case cityList(Int?, String?)
		case specialty([String])
	}
	
	enum SelectData
	{
		case cityWithMetro(ClinicWithMetro)
		case specialty([String])
	}
	
	// MARK: - Outlets
	private var tableView = createTableView()
	private var warningInfoView = LinkedTextView()
	private var applyButton = RoundEdgeButton()
	
	
	// MARK: - Variables
	private var selectData: SelectData?
	
	// MARK: - Input
	
	struct Input
	{
		let cacheData: CacheData
		let typeData: TypeData
		let cityId: Int?
	}
	
	var input: Input!

	// MARK: - Output
	
	struct Output 
	{
		let goToChat: () -> Void
		let apply: (SelectData) -> Void
	}
	
	var output: Output!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		setupUI()
	}
}


private extension ClinicTownOrSpecialtyFilterViewController
{
	static func createTableView() -> UITableView
	{
		let tableView = UITableView(frame: .zero, style: .grouped)
		tableView.rowHeight = UITableView.automaticDimension
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		tableView.registerReusableCell(ClinicTownOrSpecialtyFilterTableViewCell.id)
		tableView.sectionHeaderHeight = UITableView.automaticDimension
		tableView.estimatedSectionHeaderHeight = 75
		tableView.rowHeight = 58
		
		return tableView
	}
	
	func setupUI()
	{
		view.backgroundColor = .Background.backgroundContent
		setupSelectData()
		setupTableView()
		setupPrivacyPolicyAgreementLinks()
		setupApplyButton()
		setupTitle()
		setSelectedCells()
		updateVisibleApplyButton()
	}
	
	func setSelectedCells()
	{
		guard let selectData = selectData
		else { return }
		
		switch selectData
		{
			case .cityWithMetro(let clinic):
			
				selectCity(cityId: clinic.id)
			
			case .specialty(let specialities):
				selectSpecialities(cacheSpecialities: specialities)
		}
	}
	
	func selectCity(cityId: Int)
	{
		if case .citiesList(let list) = input.typeData,
		   let index = list.firstIndex(where: { $0.id == cityId })
		{
			tableView.selectRow(
				at: IndexPath(row: index, section: 0),
				animated: true,
				scrollPosition: .none
			)
		}
	}
	
	func selectSpecialities(cacheSpecialities: [String])
	{
		if case .specialty(let specialities) = input.typeData
		{
			var selectIndexPaths: [IndexPath] = []
			
			for (index, specialty) in specialities.values.enumerated()
			{
				cacheSpecialities.forEach
				{
					if $0 == specialty
					{
						selectIndexPaths.append(
							IndexPath(row: index, section: 0)
						)
					}
				}
			}
			
			selectIndexPaths.forEach
			{
				tableView.selectRow(
					at: $0,
					animated: true,
					scrollPosition: .none
				)
			}
		}
	}
	
	func setupSelectData()
	{
		switch input.cacheData
		{
			case .cityList(let cityId, _):
				if case .citiesList(let list) = input.typeData
				{
					if let cityId = cityId,
					   let clinicWithMetro = list.first { $0.id == cityId }
					{
						selectData = .cityWithMetro(clinicWithMetro)
					}
					else if let cityId = input.cityId,
							let clinicWithMetro = list.first { $0.id == cityId }
					{
						selectData = .cityWithMetro(clinicWithMetro)
					}
				}
			
			case .specialty(let specialties):
				selectData = .specialty(specialties)
		}
	}
	
	func updateVisibleApplyButton()
	{
		guard let selectData = selectData
		else 
		{
			applyButton.isEnabled = false
			return
		}
		
		switch input.typeData
		{
			case .citiesList:
				applyButton.isEnabled = setEnableWhenTypeDataEqualCityList(
					selectData: selectData
				)
			
			case .specialty:
				applyButton.isEnabled = setEnableWhenTypeDataEqualSpecialties(
					selectData: selectData
				)
		}
	}
	
	func setEnableWhenTypeDataEqualCityList(selectData: SelectData) -> Bool
	{
		if case .cityWithMetro(let clinicWithMetro) = selectData
		{
			if case .cityList(let cityId, _) = input.cacheData,
			   let cityId = cityId
			{
				return clinicWithMetro.id != cityId
			}
			else if let cityId = input.cityId
			{
				return clinicWithMetro.id != cityId
			}
			
			return true
		}
		
		
		return false
	}
	
	func setEnableWhenTypeDataEqualSpecialties(selectData: SelectData) -> Bool
	{
		if case .specialty(let specialties) = selectData,
		   case .specialty(let cacheSpecialties) = input.cacheData,
		   !specialties.isEmpty,
		   !cacheSpecialties.isEmpty
		{
			var isNotEqual = false
			
			if specialties.count != cacheSpecialties.count
			{
				isNotEqual = true
			}
			else
			{
				specialties.forEach
				{
					if !cacheSpecialties.contains($0)
					{
						isNotEqual = true
						return
					}
				}
			}
			
			return isNotEqual
		}
		else if case .specialty(let specialties) = selectData
		{
			return !specialties.isEmpty
		}
		
		return false
	}
	
	func setupTableView()
	{
		view.addSubview(tableView)
		tableView.edgesToSuperview()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.contentInset.bottom = 63
		tableView.allowsMultipleSelection = isMultipleSelection()
		
		func isMultipleSelection() -> Bool
		{
			switch input.typeData 
			{
				case .citiesList:
					return false
				
				case .specialty:
					return true
			}
		}
	}
	
	
	func setupPrivacyPolicyAgreementLinks()
	{
		func getText() -> String
		{
			switch input.typeData
			{
				case .citiesList:
					return NSLocalizedString("clinic_filter_city_warning_info_title", comment: "")
				
				case .specialty:
					return NSLocalizedString("clinic_filter_specialities_warning_info_title", comment: "")
			}
		}
		
		let link = LinkArea(
			text: NSLocalizedString("clinic_filter_chat_label", comment: ""),
			link: nil,
			tapHandler: { [weak self] _ in
				self?.output.goToChat()
			}
		)

		warningInfoView.textContainerInset = .zero
		
		warningInfoView.set(
			text: getText(),
			userInteractionWithTextEnabled: true,
			links: [ link ],
			textAttributes: Style.TextAttributes.primarySubhead,
			linkColor: .Text.textAccent,
			isUnderlined: false
		)
	}
	
	func setupApplyButton()
	{
		func getTitle() -> String
		{
			switch input.typeData 
			{
				case .citiesList:
					return NSLocalizedString("clinic_filter_select_title_button", comment: "")
				
				case .specialty:
					return NSLocalizedString("clinic_filter_apply_title_button", comment: "")
			}
		}
		
		view.addSubview(applyButton)
		applyButton.setTitle(getTitle(), for: .normal)
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
		guard let selectData = selectData
		else { return }
		
		self.output.apply(selectData)
	}
	
	func setupTitle()
	{
		switch input.typeData
		{
			case .citiesList:
				self.title = NSLocalizedString("clinic_filter_town_title", comment: "")
			
			case .specialty:
				self.title = NSLocalizedString("clinic_filter_speciality_title", comment: "")
			
		}
	}
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ClinicTownOrSpecialtyFilterViewController: UITableViewDataSource, UITableViewDelegate
{
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? 
	{
		createHeaderSectionView()
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat 
	{
		CGFloat.leastNonzeroMagnitude
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
	{
		switch input.typeData
		{
			case .citiesList(let list):
				return list.count
			
			case .specialty(let filter):
				return filter.values.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
	{
		switch input.typeData
		{
			case .citiesList(let list):
				guard let clinic = list[safe: indexPath.row]
				else { return UITableViewCell() }
			
				let cell = tableView.dequeueReusableCell(ClinicTownOrSpecialtyFilterTableViewCell.id)
				cell.setup(
					title: String.localizedStringWithFormat(
						NSLocalizedString("clinic_filter_city_metro_title", comment: ""),
						clinic.title
					)
				)
			
				if isSelectedCity(clinicWithMetro: clinic)
				{
					tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
				}
			
				return cell
				
			case .specialty(let filter):
				guard let title = filter.values[safe: indexPath.row]
				else { return UITableViewCell() }
		
				let cell = tableView.dequeueReusableCell(ClinicTownOrSpecialtyFilterTableViewCell.id)
				cell.setup(title: title)
			
				if isSelectedSpecialty(specialty: title)
				{
					tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
				}
			
				return cell
		}
	}
	
	private func isSelectedCity(clinicWithMetro: ClinicWithMetro) -> Bool
	{
		if let cityId = input.cityId
		{
			return clinicWithMetro.id == cityId
		}
		
		return false
	}
	
	private func isSelectedSpecialty(specialty: String) -> Bool
	{
		if case .specialty(let specialties) = input.cacheData
		{
			return specialties.contains { $0 == specialty }
		}
		
		return false
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
	{
		switch input.typeData 
		{
			case .citiesList(let list):
				guard let clinicMetro = list[safe: indexPath.row]
				else { return }
			
				if isAlreadySelectedCell(clinicMetro: clinicMetro)
				{
					tableView.deselectRow(at: indexPath, animated: true)
					selectData = nil
				}
				else
				{
					selectData = .cityWithMetro(clinicMetro)
				}
			
			case .specialty(let filter):
				guard let speciality = filter.values[safe: indexPath.row]
				else { return }
			
				self.insertOrDeleteItem(speciality: speciality)
		}
		
		updateVisibleApplyButton()
	}
	
	private func isAlreadySelectedCell(clinicMetro: ClinicWithMetro) -> Bool
	{
		guard let selectData = selectData
		else { return false }
		
		switch selectData
		{
			case .cityWithMetro(let selectedClinicMetro):
				return selectedClinicMetro.id == clinicMetro.id
			
			case .specialty:
				return false
		}
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) 
	{
		switch input.typeData
		{
			case .citiesList(let list):
				selectData = nil
			
			case .specialty(let filter):
				guard let speciality = filter.values[safe: indexPath.row]
				else { return }
			
				self.insertOrDeleteItem(speciality: speciality)
		}
		
		updateVisibleApplyButton()
	}
	
	private func insertOrDeleteItem(speciality: String)
	{
		if let selectData = selectData
		{
			var specialties = getData(selectData: selectData)
			
			if !specialties.isEmpty
			{
				if specialties.contains(where: { $0 == speciality })
				{
					specialties = specialties.filter { $0 != speciality }
				}
				else
				{
					specialties.append(speciality)
				}
				
				self.selectData = specialties.isEmpty
					? nil
					: .specialty(specialties)
			}
			else
			{
				self.selectData = .specialty([speciality])
			}
		}
		else
		{
			selectData = .specialty([speciality])
		}
	}
	
	private func getData(selectData: SelectData) -> [String]
	{
		switch selectData
		{
			case .cityWithMetro:
				return []
			
			case .specialty(let specialties):
				return specialties
		}
	}
	
	
	private func createHeaderSectionView() -> UIView
	{
		let view = UIView()
		view.backgroundColor = .clear
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.Background.backgroundTertiary
		backgroundView.clipsToBounds = true
		backgroundView.layer.cornerRadius = 10
		view.addSubview(backgroundView)
		backgroundView.edgesToSuperview(
			insets: .init(
				top: 16,
				left: 18,
				bottom: 16,
				right: 18
			)
		)
		
		let imageView = UIImageView()
		imageView.image = UIImage.Icons.info
			.resized(newWidth: 18)?
			.tintedImage(withColor: UIColor.Icons.iconAccent)
		imageView.size(
			.init(width: 18, height: 18)
		)
		backgroundView.addSubview(imageView)
		imageView.topToSuperview(offset: 12)
		imageView.leadingToSuperview(offset: 12)
		
		backgroundView.addSubview(warningInfoView)
		warningInfoView.edgesToSuperview(
			insets: .init(
				top: 12,
				left: 38,
				bottom: 12,
				right: 12
			)
		)
		
		return view
	}
}

// MARK: - Dark Theme Support

extension ClinicTownOrSpecialtyFilterViewController
{
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
	{
		super.traitCollectionDidChange(previousTraitCollection)
		
		tableView.reloadData()
	}
}
