//
//  MedicalCardFileStorageViewController.swift
//  AlfaStrah
//
//  Created by vit on 14.04.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class MedicalCardFilesStorageViewController: ViewController,
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
        let uploadFileButtonTap: () -> Void
        let menuRightNavigationItemTap: () -> Void
        let goToChat: () -> Void
        let retryFileEntryUpload: (MedicalCardFileEntry) -> Void
        let showInfoBottomSheet: (MedicalCardFileEntry) -> Void
        let renameFileEntry: (MedicalCardFileEntry) -> Void
        let removeFileEntry: (MedicalCardFileEntry) -> Void
        let removeFileEntries: (Bool, [MedicalCardFileEntry]) -> Void
        let downloadFileEntry: (MedicalCardFileEntry) -> Void
        let cancelUpload: (MedicalCardFileEntry) -> Void
        let showFileEntry: (MedicalCardFileEntry) -> Void
    }
    
    var output: Output!
        
    struct Notify {
        let updateWithState: (_ state: State) -> Void
        let selectionModeEnabled: (_ state: Bool) -> Void
        let updateFileNameToast: () -> Void
        let updateStateWhenRemoveFiles: ( _ state: State, Result<Int, AlfastrahError>) -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateWithState: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(with: state)
        },
        selectionModeEnabled: { [weak self] state in
            self?.bottomButtonsView.isHidden = !state
        },
        updateFileNameToast: { [weak self] in
            self?.showFileStateBanner(
                title: NSLocalizedString("medical_card_file_success_rename_file_title", comment: ""),
                description: "",
                hasCloseButton: false,
				iconImage: .Icons.tick,
                titleFont: Style.Font.text,
                appearance: .standard
            )
        },
        updateStateWhenRemoveFiles: { [weak self] state, result in
            guard let self = self
            else { return }
           
            self.cancelSelectionMode()
            self.update(with: state)
            
            switch result {
                case .success(let deleteFilesCount):
                    self.showFileStateBanner(
                        title: deleteFilesCount > 1
                            ? NSLocalizedString("medical_card_file_delete_files_title", comment: "")
                            : NSLocalizedString("medical_card_file_delete_file_title", comment: ""),
                        description: "",
                        hasCloseButton: false,
						iconImage: .Icons.tick,
                        titleFont: Style.Font.text,
                        appearance: .standard
                    )
                case .failure(let error):
                    self.updateStateBottomButtons()
                    ErrorHelper.show(
                        error: error,
                        text: nil,
                        alertPresenter: self.alertPresenter
                    )
            }
        }
    )
    
    private var fileStateInfoBannerView: StateInfoBannerView?
    private let operationStatusView = OperationStatusView()
    private let actionButtonsStackView = UIStackView()
    private let uploadButton = RoundEdgeButton()
    
    private let filledStateContainerView = UIView()
    private let searchBar = UISearchBar()
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private let pullToRefreshView = PullToRefreshView()
    
    private let foundFilesIsEmptyStatusView = UIView()
    
    private let bottomButtonsView = MedicalCardFilesStorageBottomButtonsView()

    private var firstWillAppear = true
    private var firstDidAppear = true
    private var state: State?

    private lazy var activateSelectionModeBarButton = createNavigationBarButton(
        title: NSLocalizedString("common_choose_button", comment: ""),
        selector: #selector(activateSelectionMode)
    )
    
    private lazy var cancelSelectionModeBarButton = createNavigationBarButton(
        title: NSLocalizedString("common_cancel_button", comment: ""),
        selector: #selector(cancelSelectionMode)
    )
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = AppLocale.currentLocale
        dateFormatter.dateFormat = "LLLL yyyy"
        return dateFormatter
    }()
        
    private var selectionModeIsActive: Bool = false {
        didSet {
            bottomButtonsView.resetSelection()
            bottomButtonsView.isHidden = !selectionModeIsActive
            actionButtonsStackView.isHidden = selectionModeIsActive
            tableView.reloadData()
            selectAllRows(false, animated: false)
            
            navigationItem.rightBarButtonItem = selectionModeIsActive
                ? cancelSelectionModeBarButton
                : activateSelectionModeBarButton
            
            searchBar.isUserInteractionEnabled = !selectionModeIsActive
            searchBar.alpha = selectionModeIsActive ? 0.4 : 1
            
            if selectionModeIsActive {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    private var fileEntriesGrouped: [MedicalCardFileEntriesGroup] = [] {
        didSet {
            updateStateBottomButtons()
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
        
        title = NSLocalizedString("medical_card_files_storage_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
        
        addCloseButton { [weak self] in
            self?.dismiss(animated: true)
        }
        
        subscribeDidBecomeActiveNotification()
        
        setupOperationStatusView()

        setupFilledStateContainerView()
        setupSearchBar()
        setupFoundFilesIsEmptyStatusView()
        setupTableView()
        setupPullToRefreshView()
        
        setupActionButtonStackView()
        setupUploadButton()
        setupBottomButtonsView()
    }
    
    private func subscribeDidBecomeActiveNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		NotificationCenter.default.removeObserver(self)
	}
    
    @objc func didBecomeActiveNotification() {
        self.input.fileEntries(nil)
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
        hideSelectionModeButtons()
        actionButtonsStackView.isHidden = true

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
            case .filled(let fileEntriesGrouped):
                let uploadsIsEmpty = fileEntriesGrouped.isEmpty
                filledStateContainerView.isHidden = uploadsIsEmpty
                operationStatusView.isHidden = !uploadsIsEmpty
                if uploadsIsEmpty {
                    if searchString.isEmpty {
                        let state: OperationStatusView.State = .info(.init(
                            title: NSLocalizedString("medical_card_files_empty_state_title", comment: ""),
                            description: NSLocalizedString("medical_card_files_empty_state_description", comment: ""),
							icon: .Illustrations.searchEmpty
                        ))
                        operationStatusView.notify.updateState(state)
                        tableView.isHidden = true
                        selectionModeIsActive = false
                        actionButtonsStackView.isHidden = false
                        foundFilesIsEmptyStatusView.isHidden = true
                        bottomButtonsView.isHidden = true
                        navigationItem.rightBarButtonItem = nil
                    }
                    else {
                        filledStateContainerView.isHidden = false
                        foundFilesIsEmptyStatusView.isHidden = false
                        tableView.isHidden = true
                        actionButtonsStackView.isHidden = true
                        navigationItem.rightBarButtonItem = selectionModeIsActive
                            ? cancelSelectionModeBarButton
                            : activateSelectionModeBarButton
                        operationStatusView.isHidden = true
                        bottomButtonsView.isHidden = !selectionModeIsActive
                    }
                }
                else {
                    operationStatusView.isHidden = true
                    filledStateContainerView.isHidden = false
                    tableView.isHidden = false
                    actionButtonsStackView.isHidden = selectionModeIsActive
                    foundFilesIsEmptyStatusView.isHidden = true
                    navigationItem.rightBarButtonItem = selectionModeIsActive
                        ? cancelSelectionModeBarButton
                        : activateSelectionModeBarButton
                    bottomButtonsView.isHidden = !selectionModeIsActive
                }

                self.fileEntriesGrouped = fileEntriesGrouped
        }
    }
	
	func reloadUI() {
		tableView.reloadData()
	}
    
    func setActivateSelectionModeBarButton(
        isEnabled: Bool
    ) {
        activateSelectionModeBarButton.isEnabled = isEnabled
    }
    
    private func setupSearchFileEntriesGrouped(
        searchString: String
    ) {
        fileEntriesGrouped = input.searchFiles(searchString)
        foundFilesIsEmptyStatusView.isHidden = !fileEntriesGrouped.isEmpty
        activateSelectionModeBarButton.isEnabled = !fileEntriesGrouped.isEmpty
        actionButtonsStackView.isHidden = !searchString.isEmpty
        tableView.isHidden = fileEntriesGrouped.isEmpty
    }
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: operationStatusView, in: view)
        )
    }
    
    private func setupActionButtonStackView() {
        view.addSubview(actionButtonsStackView)
        
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 24, left: 18, bottom: 18, right: 18)
        actionButtonsStackView.alignment = .trailing
        actionButtonsStackView.distribution = .fill
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.spacing = 0
        actionButtonsStackView.backgroundColor = .clear
        
        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        actionButtonsStackView.isHidden = true
    }
    
    private func setupUploadButton() {
        uploadButton <~ Style.RoundedButton.redBackgroundActionAlignedRight
        
        uploadButton.setTitle(
            NSLocalizedString("medical_card_file_upload_button_title", comment: ""),
            for: .normal
        )
        uploadButton.addTarget(self, action: #selector(uploadButtonTap), for: .touchUpInside)
        
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uploadButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            uploadButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth)
        ])
        
		uploadButton.setImage(.Icons.plus.tintedImage(withColor: .Text.textContrast).resized(newWidth: 16), for: .normal)
		uploadButton.tintColor = .Text.textContrast
        uploadButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        actionButtonsStackView.addArrangedSubview(uploadButton)
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
    }
    
    private func setupTableView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.registerReusableCell(MedicalCardFileTableCell.id)
        tableView.registerReusableHeaderFooter(MedicalCardStorageSectionHeader.id)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        filledStateContainerView.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: filledStateContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: filledStateContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: filledStateContainerView.bottomAnchor)
        ])
        
        tableView.backgroundColor = .clear
    }
    
    private func setupPullToRefreshView() {
        pullToRefreshView.refreshDataCallback = { [weak self] completion in
            guard let self = self
            else { return }
            
            self.input.fileEntries {
                completion()
            }
        }
            
        pullToRefreshView.scrollView = tableView
            
        view.insertSubview(pullToRefreshView, at: 0)
            
        pullToRefreshView.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
            pullToRefreshView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            pullToRefreshView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pullToRefreshView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func uploadButtonTap() {
        output.uploadFileButtonTap()
    }
    
    private func setupBottomButtonsView() {
        view.addSubview(bottomButtonsView)
        
        bottomButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
		        
        bottomButtonsView.set(items: [
            .init(
				icon: .Icons.basket,
				selectedIcon: nil,
				disabledIcon: .Icons.basket,
                action: { [weak self] _ in
                    self?.removeFilesEntries()
                },
                type: .button,
                purpose: .delete,
                isEnabled: false
            ),
            .init(
				icon: .Icons.checkbox,
				selectedIcon: .Icons.minusInFilledRoundedBox.tintedImage(withColor: .Icons.iconContrast),
				disabledIcon: .Icons.checkbox,
                action: { [weak self] selection in
                    self?.selectAllRows(selection, animated: false)
                    self?.updateStateBottomButtons()
                },
                type: .selector,
                purpose: .select,
                isEnabled: true
            )
        ])
        bottomButtonsView.isHidden = true
    }
    
    private func updateStateBottomButtons(){
        guard let isEmpty = fileEntriesGrouped.first?.fileEntries.isEmpty
        else {
            self.bottomButtonsView.selectButton.isEnabled = false
            self.bottomButtonsView.selectButton.isSelected = false
            self.bottomButtonsView.deleteButton.isEnabled = self.bottomButtonsView.selectButton.isSelected
            return
        }
        
        self.bottomButtonsView.selectButton.isEnabled = !isEmpty
        
        if let indexes = tableView.indexPathsForSelectedRows {
            self.bottomButtonsView.selectButton.isSelected = indexes.count == getCanSelectedFilesCount()
            self.bottomButtonsView.deleteButton.isEnabled = true
        } else {
            self.bottomButtonsView.selectButton.isSelected = false
            self.bottomButtonsView.deleteButton.isEnabled = false
        }
    }
    
    private func getCanSelectedFilesCount() -> Int {
        let files = fileEntriesGrouped.map { $0.fileEntries }.flatMap { $0 }
        
        return files.filter { canSelectedFile(fileEntry: $0) }.count
    }
    
    private func removeFilesEntries() {
        guard let indexPaths = tableView.indexPathsForSelectedRows
        else { return }
        
        let fileEntries = indexPaths.map {
            fileEntriesGrouped[$0.section].fileEntries[$0.row]
        }
        
        output.removeFileEntries(
            didSelectAllFiles(),
            fileEntries
        )
    }
    
    private func didSelectAllFiles() -> Bool {
        guard let indexPaths = tableView.indexPathsForSelectedRows
        else {
            return false
        }
        
        var fileEntries: [MedicalCardFileEntry] = []
        fileEntries = fileEntriesGrouped.flatMap { $0.fileEntries }
        
        if !searchString.isEmpty {
            fileEntries = fileEntries.filter {
                canSelectedFile(fileEntry: $0)
            }.filter { $0.originalFilename.lowercased().contains(searchString.lowercased())}
        }
        
        return fileEntries.count == indexPaths.count
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
        
        let cell = tableView.dequeueReusableCell(MedicalCardFileTableCell.id)
        cell.selectionModeIsActive = selectionModeIsActive
        
        cell.configure(
            searchString: searchString,
            fileEntry: fileEntry,
            imagePreviewUrl: input.imagePreviewUrl(fileEntry)
        )
        cell.statusInfoHandler = { [weak self] in
           self?.output.showInfoBottomSheet(fileEntry)
        }
        
        cell.renameCallback = { [weak self] in
            self?.output.renameFileEntry(fileEntry)
        }
        cell.removeCallback = { [weak self] in
            guard let self = self
            else { return }
            
            self.output.removeFileEntry(fileEntry)
        }
        
        cell.selectionCallback = { [weak self] in
            guard let self = self
            else { return }
            
            self.selectionModeIsActive = true
            
            tableView.selectRow(
                at: IndexPath(row: indexPath.row, section: indexPath.section),
                animated: true,
                scrollPosition: .none
            )
            self.updateStateBottomButtons()
        }
        
        cell.retryUploadCallback = { [weak self] in
            self?.output.retryFileEntryUpload(fileEntry)
        }
        
        cell.downloadCallback = { [weak self] in
            self?.output.downloadFileEntry(fileEntry)
        }
        
        cell.cancelLoadingCallback = { [weak self] in
            self?.output.cancelUpload(fileEntry)
        }
        
        cell.addContextMenu(fileEntry: fileEntry)
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        guard let fileEntry = fileEntriesGrouped[safe: indexPath.section]?.fileEntries[safe: indexPath.row]
        else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if !selectionModeIsActive {
            switch fileEntry.status {
				case .remote, .retry:
                    output.downloadFileEntry(fileEntry)
                case .uploading, .virusCheck, .error:
                    if fileEntry.localStorageFilename != nil {
                        output.showFileEntry(fileEntry)
                    } else {
                        showFileStateBanner(
                            title: NSLocalizedString("medical_card_file_is_being_processed_title", comment: ""),
                            description: NSLocalizedString("medical_card_file_is_being_processed_description", comment: ""),
                            hasCloseButton: true,
							iconImage: .Icons.info,
                            titleFont: Style.Font.headline3,
                            appearance: .standard
                        )
                    }
                case .localAndRemote:
                    output.showFileEntry(fileEntry)
                case .downloading:
                    break
            }
        }
        else {
            updateStateBottomButtons()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectionModeIsActive {
            updateStateBottomButtons()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pullToRefreshView.didScrollCallback(scrollView)
        
        guard searchBar.isFirstResponder
        else { return }
        
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        pullToRefreshView.didEndDraggingCallcback(scrollView, willDecelerate: decelerate)
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
    
    @objc private func cancelSelectionMode() {
        selectionModeIsActive = false
    }
    
    @objc private func activateSelectionMode() {
        selectionModeIsActive = true
    }
    
    private func hideSelectionModeButtons() {
        bottomButtonsView.isHidden = true
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
            
    private func selectAllRows(_ selection: Bool, animated: Bool) {
        if selection {
            for section in 0..<tableView.numberOfSections {
                for row in 0..<tableView.numberOfRows(inSection: section) {
                    if canSelectedFile(fileEntry: fileEntriesGrouped[section].fileEntries[row]) {
                        tableView.selectRow(
                            at: IndexPath(row: row, section: section),
                            animated: animated,
                            scrollPosition: .none
                        )
                    }
                }
            }
        } else {
            guard let selectedRows = tableView.indexPathsForSelectedRows
            else { return }
            
            for indexPath in selectedRows {
                tableView.deselectRow(at: indexPath, animated: animated)
            }
        }
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
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		uploadButton <~ Style.RoundedButton.redBackgroundActionAlignedRight
		uploadButton.setImage(.Icons.plus.tintedImage(withColor: .Text.textContrast).resized(newWidth: 16), for: .normal)
	}
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
        static let buttonWidth: CGFloat = 207
    }
}
