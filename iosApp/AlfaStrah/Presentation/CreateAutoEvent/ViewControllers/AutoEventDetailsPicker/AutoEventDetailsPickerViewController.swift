//
//  AutoEventDetailsPickerViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 20.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import SDWebImage

class AutoEventDetailsPickerViewController: ViewController,
											UICollectionViewDataSource,
											UICollectionViewDelegate {
	struct Input {
		let picker: BDUI.OsagoSchemeAutoPickerComponentDTO?
	}
	
	var input: Input!
	
	struct Output {
		let partsSelected: ([BDUI.SchemeItemComponentDTO]) -> Void
	}
	
	var output: Output!
	
	private var selectedParts: [BDUI.SchemeItemComponentDTO] = [] {
		didSet {
			continueButton.isEnabled = !selectedParts.isEmpty
			tagsCollectionView.reloadData()
		}
	}
	
	private lazy var continueButton = createContinueButton()
	private let schemePageView = createSchemePageView()
	private let listPageView = createListPageView()
	
	private let promptLabel = UILabel()
	
	private lazy var tagsCollectionView: UICollectionView = {
		let tagsCollectionViewLayout = UICollectionViewFlowLayout()
		tagsCollectionViewLayout.scrollDirection = .horizontal
		tagsCollectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		tagsCollectionViewLayout.minimumInteritemSpacing = 6
		tagsCollectionViewLayout.sectionInset = .init(
			top: 0,
			left: 16,
			bottom: 16,
			right: 16
		)
		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: tagsCollectionViewLayout
		)
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.registerReusableCell(AutoEventDetailsPickerTagCollectionCell.id)
		collectionView.dataSource = self
		collectionView.delegate = self
		
		return collectionView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
				
		updateSelectedPartsLocally()
		updateScheme()
		updateLists()
		
		updatePagesVisibility(selectedIndex: 0)
		
		updateTheme()
	}
		
	private func setupUI() {
		// background
		view.backgroundColor = .Background.backgroundContent
		
		// continue button
		view.addSubview(continueButton)
		continueButton.bottomToSuperview(
			offset: -15,
			usingSafeArea: true
		)
		continueButton.horizontalToSuperview(insets: .horizontal(15))
		continueButton.height(46)
		
		// prompt
		promptLabel.numberOfLines = 0
		promptLabel <~ Style.Label.secondaryText
		view.addSubview(promptLabel)
		promptLabel.topToSuperview(
			offset: 16,
			usingSafeArea: true
		)
		promptLabel.horizontalToSuperview(insets: .horizontal(16))
		
		// switch
		let switchView = RMRStyledSwitch()
		switchView.style(
			leftTitle: NSLocalizedString("auto_event_details_picker_switch_scheme_title", comment: ""),
			rightTitle: NSLocalizedString("auto_event_details_picker_switch_list_title", comment: ""),
			titleColor: .Text.textPrimary,
			backgroundColor: .Background.backgroundTertiary,
			selectedTitleColor: .Text.textPrimary,
			selectedBackgroundColor: .Background.segmentedControl
		)
		switchView.clipsToBounds = true
		switchView.addTarget(
			self,
			action: #selector(onSwitchChanged),
			for: .valueChanged
		)
		view.addSubview(switchView)
		switchView.topToBottom(
			of: promptLabel,
			offset: 19
		)
		switchView.horizontalToSuperview(insets: .horizontal(19))
		let switchViewHeight: CGFloat = 42
		switchView.height(switchViewHeight)
		switchView.layer.cornerRadius = switchViewHeight / 2
		
		// tags
		view.addSubview(tagsCollectionView)
		tagsCollectionView.topToBottom(
			of: switchView,
			offset: 16
		)
		tagsCollectionView.horizontalToSuperview()
		tagsCollectionView.height(Constants.tagsCollectionHeight)
		
		// scheme page
		view.addSubview(schemePageView)
		schemePageView.topToBottom(
			of: switchView,
			offset: 56
		)
		schemePageView.horizontalToSuperview(insets: .horizontal(16))
		schemePageView.bottomToTop(
			of: continueButton,
			offset: -14
		)
		
		// list page
		view.addSubview(listPageView)
		listPageView.topToBottom(of: tagsCollectionView)
		listPageView.horizontalToSuperview(insets: .horizontal(16))
		listPageView.bottomToTop(of: continueButton)
		
		continueButton.addTarget(self, action: #selector(continueButtonTap), for: .touchUpInside)
	}
	
	private func createContinueButton() -> RoundEdgeButton {
		let continueButton = RoundEdgeButton()
		continueButton <~ Style.RoundedButton.primaryButtonLarge
		continueButton.setTitle(
			NSLocalizedString("common_continue", comment: ""),
			for: .normal
		)
		
		return continueButton
	}
	
	@objc private func continueButtonTap() {
		output.partsSelected(self.selectedParts)
	}
	
	private static func createSchemePageView() -> AutoEventDetailPickerSchemePageView {
		let schemePageView = AutoEventDetailPickerSchemePageView()
		return schemePageView
	}
	
	private static func createListPageView() -> AutoEventDetailPickerListPageView {
		let listPageView = AutoEventDetailPickerListPageView()
		return listPageView
	}
	
	@objc func onSwitchChanged(_ sender: RMRStyledSwitch) {
		updatePagesVisibility(selectedIndex: sender.selectedIndex)
	}
	
	private func updatePagesVisibility(selectedIndex: Int) {
		switch selectedIndex {
			case 0:
				schemePageView.isHidden = false
				listPageView.isHidden = true
				
			case 1:
				schemePageView.isHidden = true
				listPageView.isHidden = false
				
			default:
				break
		}
	}
	
	private enum Constants {
		static let tagsCollectionHeight: CGFloat = 40
	}
	
	// MARK: - UICollectionViewDataSource
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return selectedParts.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(
			AutoEventDetailsPickerTagCollectionCell.id,
			indexPath: indexPath
		)
		
		if let selectedPart = selectedParts[safe: indexPath.row] {
			cell.configure(title: selectedPart.title?.text)
		}
				
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let selectedPart = selectedParts[safe: indexPath.row]
		else { return }
		
		selectedPart.isSelected = false
		updateSelectedPartsLocally()
		updateScheme()
		updateLists()
	}
	
	private func updateSelectedPartsLocally() {
		if let partsLists = input.picker?.lists {
			selectedParts = partsLists.compactMap { $0.items }.reduce([], +).filter { $0.isSelected }
		}
	}
	
	private func updateScheme() {
		if let partsLists = input.picker?.lists {
			schemePageView.configure(
				with: partsLists,
				updateSelection: { [weak self] in
					guard let self
					else { return }
					
					self.updateSelectedPartsLocally()
					self.updateLists()
				},
				singleSelection: { [weak self] ids, selectionCallback in
					guard let self
					else { return }
					
					self.showSingleSelectionBottomSheet(ids) { [weak self] partSelected in
						guard let self
						else { return }
						
						self.updateSelectedPartsLocally()
						self.updateLists()
						
						selectionCallback?(partSelected)
					}
				}
			)
		}
	}
	
	private func updateLists() {
		if let partsLists = input.picker?.lists {
			listPageView.configure(
				with: partsLists,
				updateSelection: { [weak self] in
					guard let self
					else { return }
					
					self.updateSelectedPartsLocally()
					self.updateScheme()
				}
			)
		}
	}
	
	private func createTitleView(
		for title: BDUI.ThemedSizedTextComponentDTO,
		with userInterfaceStyle: UIUserInterfaceStyle
	) -> UIView {
		let titleStackView = UIStackView()
		
		titleStackView.alignment = .center
		titleStackView.axis = .vertical
		titleStackView.distribution = .fill
		titleStackView.spacing = 2
		
		let titleLabel = UILabel()
		titleLabel <~ BDUI.StyleExtension.Label(title, for: userInterfaceStyle)
		
		titleStackView.addArrangedSubview(titleLabel)
		
		return titleStackView
	}
	
	private func updateTheme() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		if let title = input.picker?.title {
			navigationItem.titleView = self.createTitleView(
				for: title,
				with: currentUserInterfaceStyle
			)
		}
				
		if let subtitle = input.picker?.subtitle {
			promptLabel <~ BDUI.StyleExtension.Label(subtitle, for: currentUserInterfaceStyle)
		}
				
		if let button = input.picker?.button {
			continueButton <~ Style.RoundedButton.RoundedParameterizedButton(
				textColor: button.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle),
				backgroundColor: button.themedBackgroundColor?.color(for: currentUserInterfaceStyle),
				borderColor: button.themedBorderColor?.color(for: currentUserInterfaceStyle)
			)
			
			SDWebImageManager.shared.loadImage(
				with: button.leftThemedIcon?.url(for: currentUserInterfaceStyle),
				options: .highPriority,
				progress: nil,
				completed: { image, _, _, _, _, _ in
					self.continueButton.setImage(image?.resized(newWidth: 20), for: .normal)
				}
			)
		}
	}
	
	private func showSingleSelectionBottomSheet(_ parts: [Int], completion: @escaping (Bool) -> Void) {
		guard let topViewController = UIHelper.topViewController(),
			  let partsLists = input.picker?.lists
		else { return }
		
		let controller: SingleValuePickerBottomViewController = .init()
		container?.resolve(controller)
		
		let parts = partsLists.compactMap { $0.items }.reduce([], +).filter {
			if let partId = $0.id {
				return parts.contains(partId)
			}
			return false
		}
		
		var dataSource: [VehiclePartSelectable] = []
		
		for part in parts {
			if let partTitleText = part.title?.text {
				dataSource.append(
					VehiclePartSelectable(title: partTitleText, isSelected: part.isSelected)
				)
			}
		}
				
		controller.input = .init(
			title: NSLocalizedString("auto_event_detail_variant_picker_title", comment: ""),
			prompt: NSLocalizedString("auto_event_detail_variant_picker_prompt", comment: ""),
			dataSource: dataSource
		)

		controller.output = .init(
			close: { [weak topViewController] in
				topViewController?.dismiss(animated: true)
			},
			done: { [weak topViewController] selectedItem in
				var partSelected: Bool = false
				
				if let selectedIndex = dataSource.firstIndex(where: {
					$0.id == selectedItem.id
				}) {
					parts.forEach { $0.isSelected = false }
					
					if let part = parts[safe: selectedIndex] {
						part.isSelected = true
						partSelected = true
					}
				}
				
				topViewController?.dismiss(animated: true) {
					completion(partSelected)
				}
			}
		)

		topViewController.showBottomSheet(contentViewController: controller)
	}
}
