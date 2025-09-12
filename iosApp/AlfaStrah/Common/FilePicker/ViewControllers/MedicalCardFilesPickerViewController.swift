//
//  MedicalCardFilesPickerViewController.swift
//  AlfaStrah
//
//  Created by vit on 06.05.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

class MedicalCardFilesPickerViewController: ViewController,
											UISearchBarDelegate,
											UITableViewDelegate,
											UITableViewDataSource,
											UIScrollViewDelegate {
	enum State {
		case loading
		case failure
		case filled([MedicalCardFileEntriesGroup])
	}
	
	struct Input {
		let fileEntries: ((() -> Void)?) -> Void
		let imagePreviewUrl: (MedicalCardFileEntry) -> URL?
		let searchFiles: (String) -> [MedicalCardFileEntriesGroup]
	}
	
	var input: Input!
	
	struct Output {
		let goToChat: () -> Void
		let action: (MedicalCardFileEntry) -> Void
		let done: ([MedicalCardFileEntry]) -> Void
		let downloadFileEntry: (MedicalCardFileEntry) -> Void
		let retryFileEntryUpload: (MedicalCardFileEntry) -> Void
	}
	
	var output: Output!
		
	struct Notify {
		var updateWithState: (_ state: State) -> Void
	}
	
	// swiftlint:disable:next trailing_closure
	private(set) lazy var notify = Notify(
		updateWithState: { [weak self] state in
			guard let self = self,
				  self.isViewLoaded
			else { return }

			self.update(with: state)
		}
	)
	
	private var fileStateInfoBannerView: StateInfoBannerView?
	private let operationStatusView = OperationStatusView()
	private let actionButtonsStackView = UIStackView()
	private let doneButton = RoundEdgeButton()
	
	private let filledStateContainerView = UIView()
	private let searchBar = UISearchBar()
	private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
	
	private let foundFilesIsEmptyStatusView = UIView()
	
	private var firstWillAppear = true
	private var firstDidAppear = true
	private var state: State?
	
	private var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = AppLocale.currentLocale
		dateFormatter.dateFormat = "LLLL yyyy"
		return dateFormatter
	}()
	
	private var selectedFileEntries: [MedicalCardFileEntry] = []
	
	private var fileEntriesGrouped: [MedicalCardFileEntriesGroup] = [] {
		didSet {
			let entries = fileEntriesGrouped.flatMap { $0.fileEntries }
			
			/// verify selected entries after fileEntriesGrouped update
			selectedFileEntries = selectedFileEntries.filter { entries.contains($0) }
			
			tableView.reloadData()
		}
	}
	
	private var searchString: String = "" {
		didSet {
			setupSearchFileEntriesGrouped(searchString: searchString)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if firstWillAppear {
			input.fileEntries(nil)
			firstWillAppear = false
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// update must be placed here because the lottie-animation can only be started from didAppear method
		// https://github.com/airbnb/lottie-ios/issues/510#issuecomment-1092509674
		
		if firstDidAppear && state == nil {
			update(with: .loading)
			firstDidAppear = false
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = NSLocalizedString("chat_files_medical_card_pricker_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
		
		addCloseButton { [weak self] in
			self?.dismiss(animated: true)
		}
		
		setupOperationStatusView()

		setupFilledStateContainerView()
		setupSearchBar()
		setupFoundFilesIsEmptyStatusView()
		setupTableView()
		setupActionButtonStackView()
		setupDoneButton()
	}
	
	private func setupActionButtonStackView() {
		view.addSubview(actionButtonsStackView)
		
		actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
		actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 24, left: 18, bottom: 18, right: 18)
		actionButtonsStackView.alignment = .fill
		actionButtonsStackView.distribution = .fill
		actionButtonsStackView.axis = .vertical
		actionButtonsStackView.spacing = 0
		actionButtonsStackView.backgroundColor = .clear
		
		actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
		
		actionButtonsStackView.edgesToSuperview(excluding: .top)
	}
	
	private func setupDoneButton() {
		doneButton.setTitle(NSLocalizedString("common_done_button", comment: ""), for: .normal)
		doneButton.addTarget(self, action: #selector(doneTap), for: .touchUpInside)
		doneButton <~ Style.RoundedButton.primaryButtonSmall
		doneButton.height(48)
		
		actionButtonsStackView.addArrangedSubview(doneButton)
		
		doneButton.isHidden = true
		doneButton.isEnabled = false
	}
	
	@objc private func doneTap() {
		self.output.done(selectedFileEntries)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let actionButtonsStackViewBoundsHeight = actionButtonsStackView.bounds.height
		
		if tableView.contentInset.bottom != actionButtonsStackViewBoundsHeight {
			tableView.contentInset.bottom = actionButtonsStackViewBoundsHeight
		}
	}
	
	private func update(with state: State) {
		self.state = state
		
		switch state {
			case .loading:
				filledStateContainerView.isHidden = true
				operationStatusView.isHidden = false
				foundFilesIsEmptyStatusView.isHidden = true
				let state: OperationStatusView.State = .loading(.init(
					title: NSLocalizedString("medical_card_files_storage_loading_text", comment: ""),
					description: nil,
					icon: nil
				))
				operationStatusView.notify.updateState(state)
				navigationItem.rightBarButtonItem = nil
				doneButton.isHidden = true
			case .failure:
				let state: OperationStatusView.State = .info(.init(
					title: NSLocalizedString("medical_card_files_storage_loading_error_title", comment: ""),
					description: NSLocalizedString("medical_card_files_storage_loading_error_description", comment: ""),
					icon: .Icons.cross
				))
				
				let buttons: [OperationStatusView.ButtonConfiguration] = [
					.init(
						title: NSLocalizedString("common_go_to_chat", comment: ""),
						isPrimary: false,
						action: { [weak self] in
							self?.output.goToChat()
						}
					),
					.init(
						title: NSLocalizedString("common_retry", comment: ""),
						isPrimary: true,
						action: { [weak self] in
							self?.input.fileEntries(nil)
						}
					)
				]
				operationStatusView.notify.updateState(state)
				operationStatusView.notify.buttonConfiguration(buttons)
				
				navigationItem.rightBarButtonItem = nil
				doneButton.isHidden = true
				
			case .filled(let fileEntriesGrouped):
				let uploadsIsEmpty = fileEntriesGrouped.isEmpty
				filledStateContainerView.isHidden = uploadsIsEmpty
				operationStatusView.isHidden = !uploadsIsEmpty
				
				if uploadsIsEmpty {
					if searchString.isEmpty {
						let state: OperationStatusView.State = .info(.init(
							title: NSLocalizedString("medical_card_files_empty_state_title", comment: ""),
							description: NSLocalizedString("chat_files_medical_card_pricker_empty_state_description", comment: ""),
							icon: .Illustrations.searchEmpty
						))
						operationStatusView.notify.updateState(state)
						tableView.isHidden = true
						foundFilesIsEmptyStatusView.isHidden = true
					} else {
						filledStateContainerView.isHidden = false
						foundFilesIsEmptyStatusView.isHidden = false
						tableView.isHidden = true
						operationStatusView.isHidden = true
					}
					doneButton.isHidden = true
				} else {
					operationStatusView.isHidden = true
					filledStateContainerView.isHidden = false
					tableView.isHidden = false
					foundFilesIsEmptyStatusView.isHidden = true
					doneButton.isHidden = false
				}

				self.fileEntriesGrouped = fileEntriesGrouped
		}
	}
		
	private func setupSearchFileEntriesGrouped(
		searchString: String
	) {
		fileEntriesGrouped = input.searchFiles(searchString)
		foundFilesIsEmptyStatusView.isHidden = !fileEntriesGrouped.isEmpty
		tableView.isHidden = fileEntriesGrouped.isEmpty
	}
	
	private func setupOperationStatusView() {
		view.addSubview(operationStatusView)
		
		operationStatusView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate(
			NSLayoutConstraint.fill(view: operationStatusView, in: view)
		)
	}
	
	private func setupFilledStateContainerView() {
		view.addSubview(filledStateContainerView)
		
		filledStateContainerView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: filledStateContainerView, in: view))
		
		filledStateContainerView.isHidden = true
	}
	
	private func setupSearchBar() {
		filledStateContainerView.addSubview(searchBar)
		
		searchBar.delegate = self
		searchBar.placeholder = NSLocalizedString("common_search", comment: "")
		searchBar.returnKeyType = .search
		searchBar.backgroundImage = UIImage()
		
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			searchBar.topAnchor.constraint(equalTo: filledStateContainerView.topAnchor, constant: 15),
			searchBar.leadingAnchor.constraint(equalTo: filledStateContainerView.leadingAnchor, constant: 18),
			searchBar.trailingAnchor.constraint(equalTo: filledStateContainerView.trailingAnchor, constant: -18)
		])
		
		if #available(iOS 16.4, *) {
			searchBar.isEnabled = false
		} else {
			searchBar.isUserInteractionEnabled = false
			searchBar.alpha = 0.4
		}
	}
	
	private func setupTableView() {
		if #available(iOS 15.0, *) {
			tableView.sectionHeaderTopPadding = 0
		}
		
		tableView.registerReusableCell(MedicalCardFilesPickerTableCell.id)
		tableView.registerReusableHeaderFooter(MedicalCardStorageSectionHeader.id)
		
		tableView.delegate = self
		tableView.dataSource = self
		
		filledStateContainerView.addSubview(tableView)
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 15),
			tableView.leadingAnchor.constraint(equalTo: filledStateContainerView.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: filledStateContainerView.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: filledStateContainerView.bottomAnchor)
		])
		
		tableView.backgroundColor = .clear
	}
	
	private func setupFoundFilesIsEmptyStatusView() {
		view.addSubview(foundFilesIsEmptyStatusView)
		
		foundFilesIsEmptyStatusView.translatesAutoresizingMaskIntoConstraints = false
				
		let imageStatusIconView = UIImageView(image: .Illustrations.searchEmpty)
		
		foundFilesIsEmptyStatusView.addSubview(imageStatusIconView)
		imageStatusIconView.translatesAutoresizingMaskIntoConstraints = false
		
		let statusLabel = UILabel()
		foundFilesIsEmptyStatusView.addSubview(statusLabel)
		statusLabel.translatesAutoresizingMaskIntoConstraints = false
		
		statusLabel <~ Style.Label.secondaryText
		statusLabel.textAlignment = .center
		statusLabel.numberOfLines = 0
		statusLabel.text = NSLocalizedString("medical_card_files_storage_files_not_found_status", comment: "")
		
		NSLayoutConstraint.activate([
			foundFilesIsEmptyStatusView.topAnchor.constraint(greaterThanOrEqualTo: searchBar.bottomAnchor, constant: 24),
			foundFilesIsEmptyStatusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			foundFilesIsEmptyStatusView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).with(priority: .defaultHigh),
			imageStatusIconView.topAnchor.constraint(equalTo: foundFilesIsEmptyStatusView.topAnchor),
			imageStatusIconView.leadingAnchor.constraint(equalTo: foundFilesIsEmptyStatusView.leadingAnchor, constant: 40),
			imageStatusIconView.trailingAnchor.constraint(equalTo: foundFilesIsEmptyStatusView.trailingAnchor, constant: -40),
			imageStatusIconView.heightAnchor.constraint(equalToConstant: 124),
			imageStatusIconView.widthAnchor.constraint(equalTo: imageStatusIconView.heightAnchor, multiplier: 1),
			statusLabel.topAnchor.constraint(equalTo: imageStatusIconView.bottomAnchor, constant: 14),
			statusLabel.leadingAnchor.constraint(equalTo: foundFilesIsEmptyStatusView.leadingAnchor),
			statusLabel.trailingAnchor.constraint(equalTo: foundFilesIsEmptyStatusView.trailingAnchor),
			statusLabel.bottomAnchor.constraint(equalTo: foundFilesIsEmptyStatusView.bottomAnchor)
		])
		
		foundFilesIsEmptyStatusView.isHidden = true
	}
	
	// MARK: - UITableViewDelegate, UITableViewDataSource
	func numberOfSections(in tableView: UITableView) -> Int {
		return fileEntriesGrouped.count
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let fileGroup = fileEntriesGrouped[safe: section]
		else { return nil }
		
		let header = tableView.dequeueReusableHeaderFooter(MedicalCardStorageSectionHeader.id)
		let title: String
		
		switch fileGroup.kind {
			case .processing:
				title = NSLocalizedString("medical_card_table_section_proccessing_title", comment: "")
			case .search:
				title = NSLocalizedString("medical_card_files_storage_found_files_title", comment: "")
			case .successful(let date):
				title = dateFormatter.string(from: date).capitalized
		}
		header.set(title: title)
		
		return header
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let fileEntriesGroup = fileEntriesGrouped[safe: section]
		else { return 0 }
		
		return fileEntriesGroup.fileEntries.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let fileEntry = fileEntriesGrouped[safe: indexPath.section]?.fileEntries[safe: indexPath.row]
		else { return UITableViewCell() }
				
		let cell = tableView.dequeueReusableCell(MedicalCardFilesPickerTableCell.id)
		
		cell.configure(
			searchString: searchString,
			fileEntry: fileEntry,
			imagePreviewUrl: input.imagePreviewUrl(fileEntry)
		)
		
		cell.statusInfoHandler = { [weak self] in
			guard let self
			else { return }
			
			self.showInfoBottomSheet(from: self, for: fileEntry)
		}
		
		cell.selectionCallback = { [weak self] in
			guard let self
			else { return }
			
			switch fileEntry.status {
				case .downloading, .localAndRemote, .remote, .retry:
					if cell.isSelected {
						cell.setSelected(false, animated: true)
						if let index = self.selectedFileEntries.firstIndex(where: { $0 == fileEntry }) {
							self.selectedFileEntries.remove(at: index)
						}
					} else {
						cell.setSelected(true, animated: true)
						self.selectedFileEntries.append(fileEntry)
					}

					self.doneButton.isEnabled = !self.selectedFileEntries.isEmpty
					
				case .error, .uploading, .virusCheck:
					break
					
			}
		}
		
		cell.imageTapCallback = { [weak self] in
			fileEntry.setStateObserver { _ in
				cell.applyCellState(MedicalCardFilesPickerTableCell.state(for: fileEntry))
			}
			
			self?.output.action(fileEntry)
		}
				
		return cell
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let fileEntry = fileEntriesGrouped[safe: indexPath.section]?.fileEntries[safe: indexPath.row]
		else { return }
		
		if selectedFileEntries.contains(fileEntry) {
			cell.setSelected(true, animated: false)
		}
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
				
	private func createNavigationBarButton(
		title: String,
		selector: Selector
	) -> UIBarButtonItem {
		
		let barButtonItem = UIBarButtonItem(
			title: title,
			style: .plain,
			target: self,
			action: selector
		)
		
		barButtonItem <~ Style.Button.NavigationItemRed(title: title)

		return barButtonItem
	}
	
	private func canSelectedFile(fileEntry: MedicalCardFileEntry) -> Bool {
		fileEntry.status != .uploading
	}
	
	// MARK: - Status Banner
	private func removePreviousFileStateBannerViewIfNeeded() {
		guard let fileStateInfoBannerView = self.fileStateInfoBannerView,
			  let navigationController = self.navigationController
		else { return }
		
		if fileStateInfoBannerView.isDescendant(of: navigationController.view) {
			fileStateInfoBannerView.removeFromSuperview()
		}
		
		self.fileStateInfoBannerView = nil
	}
	
	func showFileStateBanner(
		title: String,
		description: String,
		hasCloseButton: Bool,
		iconImage: UIImage?,
		titleFont: UIFont,
		appearance: StateInfoBannerView.Appearance
	) {
		removePreviousFileStateBannerViewIfNeeded()
		
		let fileStateInfoBannerView = StateInfoBannerView()
		
		self.fileStateInfoBannerView = fileStateInfoBannerView
		
		fileStateInfoBannerView.translatesAutoresizingMaskIntoConstraints = false
		
		if let navigationController = self.navigationController {
			let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
			navigationController.view.addSubview(fileStateInfoBannerView)
			
			NSLayoutConstraint.activate([
				fileStateInfoBannerView.topAnchor.constraint(equalTo: navigationController.view.topAnchor, constant: statusBarHeight + 9),
				fileStateInfoBannerView.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor, constant: 18),
				fileStateInfoBannerView.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor, constant: -18)
			])
			
			let fileStateInfoBannerViewOffset = fileStateInfoBannerView.frame.origin.y + fileStateInfoBannerView.frame.height
			
			fileStateInfoBannerView.set(
				appearance: appearance,
				title: title,
				description: description,
				hasCloseButton: hasCloseButton,
				iconImage: iconImage,
				titleFont: titleFont,
				startBannerOffset: -(fileStateInfoBannerViewOffset + statusBarHeight)
			)
		}
		fileStateInfoBannerView.setupTimer()
	}
	
	private func showInfoBottomSheet(from viewController: ViewController, for fileEntry: MedicalCardFileEntry) {
		func descriptionLabel(_ text: String) -> UILabel {
			let description = UILabel()
			description <~ Style.Label.primaryText
			description.numberOfLines = 0
			description.text = text
			return description
		}

		func subtitleLabel(_ text: String) -> UILabel {
			let subtitleLabel = UILabel()
			subtitleLabel.numberOfLines = 0
			subtitleLabel <~ Style.Label.primaryHeadline3
			subtitleLabel.text = text
			return subtitleLabel
		}
		
		switch fileEntry.status {
			case .uploading:
				MedicalCardInfoBottomSheet.present(
					from: viewController,
					title: NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_title", comment: ""),
					buttonTitle: NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_button_title", comment: ""),
					additionalViews: [
						descriptionLabel(NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_description", comment: "")),
						spacer(6),
						descriptionLabel(NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_secondary_description", comment: "")),
						spacer(15),
						subtitleLabel(NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_subtitle", comment: "")),
						spacer(6),
						descriptionLabel(NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_subdescription", comment: ""))
					],
					fileEntry: fileEntry
				)
				
			case .virusCheck:
				MedicalCardInfoBottomSheet.present(
					from: viewController,
					title: NSLocalizedString("chat_files_virus_check_info_bottom_sheet_title", comment: ""),
					buttonTitle: NSLocalizedString("chat_files_common_bottom_sheet_button_title", comment: ""),
					additionalViews: [
						descriptionLabel(NSLocalizedString("chat_files_virus_check_info_bottom_sheet_description", comment: "")),
						spacer(15),
						subtitleLabel(NSLocalizedString("chat_files_virus_check_info_bottom_sheet_subtitle", comment: "")),
						spacer(6),
						descriptionLabel(NSLocalizedString("chat_files_virus_check_info_bottom_sheet_subdescription", comment: ""))
					],
					fileEntry: fileEntry
				)
				
			case .error:
				switch fileEntry.errorType {
					case .common, .typeNotSupported, .none:
						MedicalCardInfoBottomSheet.present(
							from: viewController,
							title: NSLocalizedString("medical_card_files_error_info_bottom_sheet_title", comment: ""),
							buttonTitle: NSLocalizedString("medical_card_files_error_info_bottom_sheet_description", comment: ""),
							additionalViews: [
								descriptionLabel(NSLocalizedString("medical_card_files_error_info_bottom_sheet_description", comment: ""))
							],
							fileEntry: fileEntry,
							action: { [weak self] in
								self?.output.retryFileEntryUpload(fileEntry)
							},
							completion: {}
						)
					case .virusOccured:
						MedicalCardInfoBottomSheet.present(
							from: viewController,
							title: NSLocalizedString("chat_files_virus_occured_info_bottom_sheet_title", comment: ""),
							buttonTitle: NSLocalizedString("chat_files_common_bottom_sheet_button_title", comment: ""),
							additionalViews: [
								descriptionLabel(NSLocalizedString("chat_files_virus_occured_info_bottom_sheet_description", comment: ""))
							],
							fileEntry: fileEntry,
							completion: {}
						)
				}
				
			case .remote:
				MedicalCardInfoBottomSheet.present(
					from: viewController,
					title: NSLocalizedString("chat_files_remote_info_bottom_sheet_title", comment: ""),
					buttonTitle: NSLocalizedString("chat_files_download_bottom_sheet_button_title", comment: ""),
					additionalViews: [
						descriptionLabel(NSLocalizedString("chat_files_remote_info_bottom_sheet_description", comment: ""))
					],
					fileEntry: fileEntry,
					action: { [weak self] in
						self?.output.downloadFileEntry(fileEntry)
					},
					completion: {}
				)
				
			case .downloading:
				MedicalCardInfoBottomSheet.present(
					from: viewController,
					title: NSLocalizedString("chat_files_downloading_info_bottom_sheet_title", comment: ""),
					buttonTitle: NSLocalizedString("chat_files_common_bottom_sheet_button_title", comment: ""),
					additionalViews: [
						descriptionLabel(NSLocalizedString("chat_files_downloading_info_bottom_sheet_description", comment: ""))
					],
					fileEntry: fileEntry,
					completion: {}
				)
				
			case .localAndRemote:
				break
				
			case .retry:
				MedicalCardInfoBottomSheet.present(
					from: viewController,
					title: NSLocalizedString("chat_files_download_error_info_bottom_sheet_title", comment: ""),
					buttonTitle: NSLocalizedString("chat_files_download_retry_bottom_sheet_button_title", comment: ""),
					additionalViews: [
						descriptionLabel(NSLocalizedString("chat_files_download_error_info_bottom_sheet_description", comment: ""))
					],
					fileEntry: fileEntry,
					action: { [weak self] in
						self?.output.downloadFileEntry(fileEntry)
					},
					completion: {}
				)
		}
	}
			
	struct Constants {
		static let buttonHeight: CGFloat = 48
		static let buttonWidth: CGFloat = 207
	}
}
