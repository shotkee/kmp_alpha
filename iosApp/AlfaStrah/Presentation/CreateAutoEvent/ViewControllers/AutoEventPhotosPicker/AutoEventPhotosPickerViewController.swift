//
//  AutoEventPhotosPickerViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 12.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import SDWebImage

class AutoEventPhotosPickerViewController: ViewController,
										   UICollectionViewDataSource,
										   UICollectionViewDelegate,
										   UICollectionViewDelegateFlowLayout {
	struct Input {
		let picker: BDUI.OsagoPhotoUploadPickerComponentDTO?
		let fileEntries: () -> [FilePickerFileEntry]
	}
	
	var input: Input!
	
	struct Output {
		let addPhoto: () -> Void
		let showPhoto: () -> Void
		let deletePhoto: (Attachment) -> Void
		let close: () -> Void
		let save: () -> Void
	}
	
	var output: Output!
	
	private let fadeView = createFadeView()
	private let sheetView = createSheetView()
	private lazy var sheetCardView = createSheetCardView()
	private let photosCollectionLayout = createPhotosCollectionLayout()
	private lazy var photosCollectionView = createPhotosCollectionView()
	
	private let titleLabel = UILabel()
	private let photosCountLabel = UILabel()
	private let saveButton = RoundEdgeButton()
	private let errorLabel = UILabel()
	
	private let actionButtonsStackView = UIStackView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		
		updateTheme()
	}

	override var modalPresentationStyle: UIModalPresentationStyle {
		get {
			return .overFullScreen
		}
		set {
			// ignore
		}
	}
			
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		animateIn()
	}
	
	private func setupUI() {
		// background
		view.backgroundColor = .clear
		
		// fade
		view.addSubview(fadeView)
		fadeView.edgesToSuperview()
		
		// sheet
		view.addSubview(sheetCardView)
		sheetCardView.edgesToSuperview(excluding: .top)
		sheetCardView.topToSuperview(
			offset: 44,
			usingSafeArea: true
		)
		sheetCardView.isHidden = true
		
		// close button
		let closeButton = UIButton(type: .system)
		closeButton.setImage(
			.Icons.cross,
			for: .normal
		)
		closeButton.tintColor = .Icons.iconAccent
		closeButton.addTarget(
			self,
			action: #selector(onCloseButton),
			for: .touchUpInside
		)
		sheetView.addSubview(closeButton)
		closeButton.trailingToSuperview(offset: 10)
		closeButton.topToSuperview(offset: 15)
		closeButton.height(40)
		closeButton.aspectRatio(1)
		
		// title
		titleLabel.text = input.picker?.uploadScreen?.title?.text
		titleLabel <~ Style.Label.primaryHeadline1
		titleLabel.numberOfLines = 0
		sheetView.addSubview(titleLabel)
		titleLabel.leadingToSuperview(offset: 18)
		titleLabel.trailingToLeading(of: closeButton)
		titleLabel.topToSuperview(offset: 23)
		titleLabel.setHugging(
			.required,
			for: .vertical
		)
		
		// save button
		saveButton <~ Style.RoundedButton.primaryButtonLarge
		saveButton.setTitle(
			NSLocalizedString("common_save", comment: ""),
			for: .normal
		)
		saveButton.height(46)
		saveButton.isEnabled = false
		saveButton.addTarget(self, action: #selector(saveButtonTap), for: .touchUpInside)
		
		// stack
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 0
		stackView.alignment = .center
		sheetView.addSubview(stackView)
		stackView.topToBottom(
			of: titleLabel,
			offset: 24
		)
		stackView.horizontalToSuperview()
		stackView.bottomToSuperview()
		
		// info view
		if let informationWidget = input.picker?.uploadScreen?.information {
			let infoViewContainer = UIView()
			infoViewContainer.backgroundColor = .clear
			stackView.addArrangedSubview(infoViewContainer)
			infoViewContainer.leadingToSuperview(offset: 16)
			
			let infoView = BDUI.ViewBuilder.constructWidgetView(
				for: informationWidget,
				handleEvent: { _ in }
			)
			
			infoViewContainer.addSubview(infoView)
			infoView.edgesToSuperview()
		}
				
		// photos view
		let photosView = UIView()
		photosView.backgroundColor = .clear
		stackView.addArrangedSubview(photosView)
		photosView.leadingToSuperview(offset: 16)
		
		// max photos count
		var maxCountString: String?
		
		if let maxCount = input.picker?.countMax {
			let localized = NSLocalizedString(
				"bdui_osago_photo_count",
				comment: ""
			)
			
			maxCountString = String(
				format: localized,
				locale: .init(identifier: "ru"),
				maxCount
			)
		}
		
		let maxPhotosCountLabel = UILabel()
		maxPhotosCountLabel.numberOfLines = 0
		maxPhotosCountLabel.text = maxCountString
		maxPhotosCountLabel <~ Style.Label.primaryHeadline1
		photosView.addSubview(maxPhotosCountLabel)
		maxPhotosCountLabel.edgesToSuperview(excluding: .bottom)
		maxPhotosCountLabel.setHugging(
			.required,
			for: .vertical
		)
		
		// photos count
		photosCountLabel.numberOfLines = 0
		photosCountLabel <~ Style.Label.secondaryText
		photosView.addSubview(photosCountLabel)
		photosCountLabel.topToBottom(
			of: maxPhotosCountLabel,
			offset: 5
		)
		photosCountLabel.horizontalToSuperview()
		photosCountLabel.setHugging(
			.required,
			for: .vertical
		)
		
		// photos
		photosView.addSubview(photosCollectionView)
		photosCollectionView.topToBottom(of: photosCountLabel)
		photosCollectionView.edgesToSuperview(excluding: .top)
		
		let containerView = UIView()
		containerView.backgroundColor = .Background.backgroundModal
		
		sheetView.addSubview(containerView)
		containerView.edgesToSuperview(excluding: .top)
		
		containerView.addSubview(actionButtonsStackView)
				
		actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
		actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 9, left: 15, bottom: 15, right: 15)
		actionButtonsStackView.alignment = .fill
		actionButtonsStackView.distribution = .fill
		actionButtonsStackView.axis = .vertical
		actionButtonsStackView.spacing = 16
		actionButtonsStackView.backgroundColor = .clear
		
		actionButtonsStackView.bottomToSuperview(
			usingSafeArea: true
		)
		actionButtonsStackView.edgesToSuperview(excluding: .bottom)
		
		errorLabel <~ Style.Label.accentText
		errorLabel.textAlignment = .center
		errorLabel.numberOfLines = 0
		errorLabel.isHidden = true
		
		actionButtonsStackView.addArrangedSubview(errorLabel)
		actionButtonsStackView.addArrangedSubview(saveButton)
		
		updateUI()
	}
	
	@objc private func saveButtonTap() {
		output.save()
	}
	
	private static func createFadeView() -> UIView {
		let fadeView = UIView()
		fadeView.backgroundColor = .Other.overlayPrimary
		return fadeView
	}
	
	private static func createSheetView() -> UIView {
		let sheetView = UIView()
		sheetView.backgroundColor = .Background.backgroundModal
		return sheetView
	}
	
	private func createSheetCardView() -> UIView {
		return sheetView.embedded(
			hasShadow: true,
			cornerSide: .top,
			shadowStyle: .elevation2
		)
	}
	
	@objc private func onCloseButton() {
		self.showCloseAlert { [weak self] in
			self?.animateOut { [weak self] in
				self?.output.close()
			}
		}
	}
	
	private static func createPhotosCollectionLayout() -> UICollectionViewFlowLayout {
		let photosCollectionViewLayout = UICollectionViewFlowLayout()
		photosCollectionViewLayout.scrollDirection = .vertical
		photosCollectionViewLayout.sectionInset = .init(
			top: 24,
			left: 0,
			bottom: 24,
			right: 0
		)
		photosCollectionViewLayout.minimumLineSpacing = 12
		photosCollectionViewLayout.minimumInteritemSpacing = 12
		return photosCollectionViewLayout
	}
	
	private func createPhotosCollectionView() -> UICollectionView {
		let photosCollectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: photosCollectionLayout
		)
		
		photosCollectionView.backgroundColor = .clear

		photosCollectionView.registerReusableCell(AutoEventPhotosPickerAddCollectionCell.id)
		photosCollectionView.registerReusableCell(AutoEventPhotosPickerPhotoCollectionCell.id)
		photosCollectionView.dataSource = self
		photosCollectionView.delegate = self
		return photosCollectionView
	}
	
	private func animateIn() {
		fadeView.alpha = 0
		sheetCardView.transform = .init(
			translationX: 0,
			y: sheetCardView.bounds.height
		)
		sheetCardView.isHidden = false
		
		UIView.animate(
			withDuration: Constants.animationDuration,
			delay: 0,
			options: .curveEaseIn,
			animations: {
				self.fadeView.alpha = 1
				self.sheetCardView.transform = .identity
			}
		)
	}
	
	private func animateOut(_ completion: @escaping () -> Void) {
		UIView.animate(
			withDuration: Constants.animationDuration,
			delay: 0,
			options: .curveEaseOut,
			animations: {
				self.fadeView.alpha = 0
				self.sheetCardView.transform = .init(
					translationX: 0,
					y: self.sheetCardView.bounds.height
				)
			},
			completion: { _ in
				completion()
			}
		)
	}
	
	enum Constants {
		static let animationDuration: TimeInterval = 0.2
	}
	
	private func updateUI() {
		let readyFileEntriesCount = input.fileEntries().filter {
			switch $0.state {
				case .ready:
					return true
				case .error, .processing:
					return false
			}
		}.count
		
		let photoCountText = String(
			format:
				NSLocalizedString("bdui_osago_upload_photos_count", comment: ""),
				"\(readyFileEntriesCount)"
		)
		
		photosCountLabel.text = photoCountText
				
		saveButton.isEnabled = 
			(readyFileEntriesCount <= input.picker?.countMax ?? Int.max)
			&& (readyFileEntriesCount >= input.picker?.countMin ?? 0) 
			&& readyFileEntriesCount != 0
			&& readyFileEntriesCount == input.fileEntries().count
		
		let errorFileEntriesCount = input.fileEntries().filter {
			switch $0.state {
				case .ready, .processing:
					return false
				case .error:
					return true
			}
		}.count
		
		let localized = NSLocalizedString(
			"bdui_upload_files_error",
			comment: ""
		)
			
		let errorText = String(
			format: localized,
			locale: .init(identifier: "ru"),
			errorFileEntriesCount
		)
		
		errorLabel.text = "\(errorText)\n\(NSLocalizedString("bdui_osago_filepicker_retry_upload_file", comment: ""))"
		errorLabel.isHidden = errorFileEntriesCount == 0
	}
	
	private func reloadData() {
		photosCollectionView.reloadData()
		
		updateUI()
	}
	
	// MARK: - UICollectionViewDataSource
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1 + input.fileEntries().count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.item == 0 {
			let cell = collectionView.dequeueReusableCell(
				AutoEventPhotosPickerAddCollectionCell.id,
				indexPath: indexPath
			)
			
			cell.setState(
				isActive: {
					return input.fileEntries().count < (input.picker?.countMax ?? 0)
				}()
			)
			
			return cell
		} else {
			let entry = input.fileEntries()[indexPath.row - 1]
			
			let cell = collectionView.dequeueReusableCell(
				AutoEventPhotosPickerPhotoCollectionCell.id,
				indexPath: indexPath
			)
			entry.setStateObserver { [weak self] state in
				DispatchQueue.main.async { [weak self] in
					guard let self
					else { return }
					
					let photoUrl: URL?
					
					switch state {
						case .ready(previewUrl: let url, attachment: _):
							photoUrl = url
						case
							.error(previewUrl: let url, attachment: _, _),
							.processing(previewUrl: let url, _, _):
							photoUrl = url
							
					}
					
					cell.configure(
						with: photoUrl,
						originalName: nil,
						pathExtension: nil,
						for: self.cellState(entryState: state)
					)
					
					self.entryStateChanged(entry)
					
					updateUI()
				}
			}
			
			cell.prepareForReuseCallback = {
				entry.deleteStateObserver()
			}
			
			cell.configure(
				with: entry.attachment?.url,
				originalName: nil,
				pathExtension: nil,
				for: self.cellState(entryState: entry.state)
			)
			
			cell.deleteHandler = { [weak self] in
				self?.deleteSelected(index: indexPath.item - 1)
			}
			
			return cell
		}
	}
	
	private func entryStateChanged(_ entry: FilePickerFileEntry) {
		updateUI()
	}
	
	private func cellState(entryState: FilePickerEntryState) -> AutoEventPhotosPickerPhotoCollectionCell.State {
		switch entryState {
			 case .ready:
				 return .ready
			 case .processing:
				 return .processing
			 case .error:
				 return .error
		}
	}
	
	private func deleteSelected(index: Int) {
		if let attachment = input.fileEntries()[safe: index]?.attachment {
			output.deletePhoto(attachment)
			reloadData()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.item == 0 && input.fileEntries().count < (input.picker?.countMax ?? 0) {
			output.addPhoto()
			reloadData()
		} else {
			output.showPhoto()
		}
	}
	
	// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
	
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		let itemsPerRow = CGFloat(3)
		let spacing = photosCollectionLayout.minimumInteritemSpacing
		let width = (collectionView.bounds.width - (itemsPerRow - 1) * spacing) / itemsPerRow
		return .init(
			width: width,
			height: width
		)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		if let title = input.picker?.uploadScreen?.title {
			titleLabel <~ BDUI.StyleExtension.Label(title, for: currentUserInterfaceStyle)
		}
	}
	
	private func showCloseAlert(
		completion: @escaping () -> Void
	) {
		let alert = UIAlertController(
			title: nil,
			message: NSLocalizedString("bdui_osago_filepicker_sheet_close_alert_title", comment: ""),
			preferredStyle: .alert
		)

		let cancelAction = UIAlertAction(
			title: NSLocalizedString("bdui_osago_filepicker_sheet_close_alert_cancel_title", comment: ""),
			style: .cancel
		)

		let buyAction = UIAlertAction(
			title: NSLocalizedString("bdui_osago_filepicker_sheet_close_alert_positive_decision_title", comment: ""),
			style: .default
		) { _ in
			completion()
		}

		alert.addAction(buyAction)
		alert.addAction(cancelAction)

		self.present(alert, animated: true)
	}
}
