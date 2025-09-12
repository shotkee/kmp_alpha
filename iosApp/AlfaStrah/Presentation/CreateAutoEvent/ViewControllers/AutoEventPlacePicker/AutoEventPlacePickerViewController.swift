//
//  AutoEventPlacePickerViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 08.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import YandexMapsMobile
import CoreLocation
import TinyConstraints
import Legacy
import SDWebImage

class AutoEventPlacePickerViewController: ViewController,
										  GeolocationServiceDependency,
										  GeocodeServiceDependency,
										  YMKMapInputListener,
										  UITableViewDataSource,
										  UITableViewDelegate {
	var geocodeService: GeocodeService!
	var geoLocationService: GeoLocationService!
	
	private let mapView = YMKMapView()
	private let mapOverlayView = createMapOverlayView()
	private var placeSheetStackViewBottomConstraint: NSLayoutConstraint?
	private lazy var suggestionsTableView = createSuggestionsTableView()
	private let mapButtonsStackView = createMapButtonsStackView()
	private lazy var zoomInButton = createZoomInButton()
	private lazy var zoomOutButton = createZoomOutButton()
	private lazy var userLocationButton = createUserLocationButton()
	private var rightBarButton: UIBarButtonItem?
	
	private let placeInputView = CommonTextInput()
	private let placeSheetTitleLabel = UILabel()
	private let placeSheetPromptLabel = UILabel()
	private let saveButton = RoundEdgeButton()
	
	struct PickerConfiguration {
		let title: BDUI.ThemedSizedTextComponentDTO?
		let modalTitle: BDUI.ThemedSizedTextComponentDTO?
		let subtitle: BDUI.ThemedSizedTextComponentDTO?
		let button: BDUI.ButtonWidgetDTO?
		let allowMapSelect: Bool
	}
	
	private var positionWasManuallySet = false
	private var didAppearFired = false
		
	struct Input {
		let pickerConfiguration: PickerConfiguration
		let initialGeoPlace: GeoPlace?
		let initialPosition: Coordinate?
		let requestGeoPlaces: (_ searchString: String, _ completion: @escaping ([GeoPlace]) -> Void ) -> Void
	}
		
	var input: Input!
	
	struct Output {
		let positionSelected: (_ coordinate: Coordinate) -> Void
		let locationSelected: (_ geoPlaceIndex: Int) -> Void
	}
	
	var output: Output!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupLocationServices()
		
		setupUI()
		setupMapView()
		updateTheme()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
				
		if let initialGeoPlace = input.initialGeoPlace {
			self.handleSelected(geoPlace: initialGeoPlace)
		} else if let initialPosition = input.initialPosition {
			self.handleSelected(position: initialPosition)
		} else if !positionWasManuallySet {
			updateLocation()
		}
								
		didAppearFired = true // do not allow updateTheme method to set pin before calc current position
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		didAppearFired = false
	}
			
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		mapView.mapWindow.map.isNightModeEnabled = traitCollection.userInterfaceStyle == .dark
		
		if let title = input.pickerConfiguration.title {
			navigationItem.titleView = self.createTitleView(
				for: title,
				with: currentUserInterfaceStyle
			)
		}
		
		if let modalTitle = input.pickerConfiguration.modalTitle {
			placeSheetTitleLabel <~ BDUI.StyleExtension.Label(modalTitle, for: currentUserInterfaceStyle)
		}
		
		if let subtitle = input.pickerConfiguration.subtitle {
			placeSheetPromptLabel <~ BDUI.StyleExtension.Label(subtitle, for: currentUserInterfaceStyle)
		}
		
		if let currentPosition, didAppearFired {
			updateLocationPin(
				on: self.mapView.mapWindow.map,
				with: YMKPoint(latitude: currentPosition.latitude, longitude: currentPosition.longitude)
			)
		}
		
		if let button = input.pickerConfiguration.button {
			saveButton <~ Style.RoundedButton.RoundedParameterizedButton(
				textColor: button.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle),
				backgroundColor: button.themedBackgroundColor?.color(for: currentUserInterfaceStyle),
				borderColor: button.themedBorderColor?.color(for: currentUserInterfaceStyle)
			)
			
			SDWebImageManager.shared.loadImage(
				with: button.leftThemedIcon?.url(for: currentUserInterfaceStyle),
				options: .highPriority,
				progress: nil,
				completed: { image, _, _, _, _, _ in
					self.saveButton.setImage(image?.resized(newWidth: 20), for: .normal)
				}
			)
		}
		
		updateMapButtons()
	}
	
	// swiftlint:disable:next function_body_length
	private func setupUI() {
		// background
		view.backgroundColor = .Background.backgroundContent
				
		// map
		view.addSubview(mapView)
		mapView.topToSuperview(usingSafeArea: true)
		mapView.edgesToSuperview(excluding: .top)
		
		// map overlay
		mapOverlayView.alpha = 0
		view.addSubview(mapOverlayView)
		mapOverlayView.edgesToSuperview()
		
		// place sheet
		let placeSheetView = UIView()
		placeSheetView.backgroundColor = .Background.backgroundModal
		
		// place sheet card
		let placeSheetCardView = placeSheetView.embedded(
			hasShadow: true,
			cornerSide: .top,
			shadowStyle: .elevation2
		)
		view.addSubview(placeSheetCardView)
		placeSheetCardView.edgesToSuperview(excluding: .top)
		placeSheetCardView.topToSuperview(
			offset: -32,
			priority: .defaultHigh,
			usingSafeArea: true
		)
		
		// place sheet stack
		let placeSheetStackView = UIStackView()
		placeSheetStackView.axis = .vertical
		placeSheetStackView.spacing = 16
		placeSheetView.addSubview(placeSheetStackView)
		placeSheetStackView.topToSuperview(offset: 15)
		placeSheetStackView.horizontalToSuperview(insets: .horizontal(18))
		placeSheetStackViewBottomConstraint = placeSheetStackView.bottomToSuperview(isActive: false)
		
		// place sheet title
		placeSheetTitleLabel <~ Style.Label.primaryTitle1
		placeSheetStackView.addArrangedSubview(placeSheetTitleLabel)
		placeSheetTitleLabel.setHugging(
			.required,
			for: .vertical
		)
		
		// place sheet prompt
		placeSheetPromptLabel.numberOfLines = 0
		placeSheetPromptLabel <~ Style.Label.secondaryText
		placeSheetStackView.addArrangedSubview(placeSheetPromptLabel)
		placeSheetPromptLabel.setHugging(
			.required,
			for: .vertical
		)
		
		// place input
		placeInputView.shoudValidate = false
		placeInputView.textField.placeholder = NSLocalizedString("auto_event_place_picker_place_input_placeholder", comment: "")
		placeInputView.textField.addTarget(self, action: #selector(inputEditingBegin), for: .editingDidBegin)
		placeInputView.textField.addTarget(self, action: #selector(inputEditingChanged), for: .editingChanged)
		placeInputView.textField.addTarget(self, action: #selector(inputEditingEnd), for: .editingDidEnd)
		placeSheetStackView.addArrangedSubview(placeInputView)
		
		// suggestions table
		placeSheetStackView.addArrangedSubview(suggestionsTableView)
		suggestionsTableView.isHidden = true
		
		// save button
		saveButton <~ Style.RoundedButton.primaryButtonLarge
		placeSheetView.addSubview(saveButton)
		saveButton.topToBottom(
			of: placeSheetStackView,
			offset: 32,
			priority: .defaultHigh
		)
		saveButton.horizontalToSuperview(insets: .horizontal(15))
		saveButton.height(46)
		saveButton.bottomToSuperview(
			offset: -17,
			usingSafeArea: true
		)
		saveButton.addTarget(self, action: #selector(saveButtonTap), for: .touchUpInside)
		
		saveButton.setTitle(input.pickerConfiguration.button?.themedTitle?.text, for: .normal)
		
		// map buttons stack
		view.addSubview(mapButtonsStackView)
		mapButtonsStackView.bottomToTop(
			of: placeSheetCardView,
			offset: -11
		)
		mapButtonsStackView.trailingToSuperview(offset: 16)
		
		// zoom in button
		mapButtonsStackView.addArrangedSubview(zoomInButton)
		
		// zoom out button
		mapButtonsStackView.addArrangedSubview(zoomOutButton)
		mapButtonsStackView.setCustomSpacing(
			20,
			after: zoomOutButton
		)
		
		// user location button
		mapButtonsStackView.addArrangedSubview(userLocationButton)
		
		// handle keyboard
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(onKeyboardWillShow),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(onKeyboardWillChangeFrame),
			name: UIResponder.keyboardWillChangeFrameNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(onKeyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}
	
	@objc private func saveButtonTap() {
		switch selectionKind {
			case .mapTap:
				if let currentPosition {
					output.positionSelected(currentPosition)
				}
				
			case .geoPlaceSelection:
				if let currentGeoPlace,
				   let index = self.geoPlaces.firstIndex(where: { $0 == currentGeoPlace }) {
					output.locationSelected(index)
				}
				
			case .none:
				break
		}
	}
		
	private func setupMapView() {
		let map = mapView.mapWindow.map
		
		map.mapType = .vectorMap
		map.isRotateGesturesEnabled = false
		map.addInputListener(with: self)
	}
	
	private static func createMapOverlayView() -> UIView {
		let mapOverlayView = UIView()
		mapOverlayView.backgroundColor = .Other.overlayPrimary
		return mapOverlayView
	}
	
	private func createSuggestionsTableView() -> UITableView {
		let suggestionsTableView = UITableView()
		suggestionsTableView.backgroundColor = .clear
		suggestionsTableView.separatorStyle = .none
		suggestionsTableView.registerReusableCell(AutoEventPlacePickerSuggestionTableCell.id)
		suggestionsTableView.dataSource = self
		suggestionsTableView.delegate = self
				
		return suggestionsTableView
	}
	
	private static func createMapButtonsStackView() -> UIStackView {
		let mapButtonsStackView = UIStackView()
		mapButtonsStackView.axis = .vertical
		mapButtonsStackView.spacing = 12
		return mapButtonsStackView
	}
	
	private func createZoomInButton() -> UIButton {
		let zoomInButton = Self.createMapButton(image: .Icons.plus)
		zoomInButton.addTarget(
			self,
			action: #selector(onZoomInButton),
			for: .touchUpInside
		)
		return zoomInButton
	}
	
	private func createZoomOutButton() -> UIButton {
		let zoomOutButton = Self.createMapButton(image: .Icons.minus)
		zoomOutButton.addTarget(
			self,
			action: #selector(onZoomOutButton),
			for: .touchUpInside
		)
		return zoomOutButton
	}
	
	private func createUserLocationButton() -> UIButton {
		let userLocationButton = Self.createMapButton(image: .Icons.geoposition)
		userLocationButton.addTarget(
			self,
			action: #selector(onUserLocationButton),
			for: .touchUpInside
		)
		return userLocationButton
	}
	
	private static func createMapButton(image: UIImage?) -> UIButton {
		let button = UIButton()
		button.setImage(
			image,
			for: .normal
		)
		button.tintColor = .Icons.iconPrimary
		button.width(Constants.mapButtonWidth)
		button.aspectRatio(1)
		
		button.clipsToBounds = false
		button.layer.shadowRadius = 18
		button.layer.shadowOffset = .init(
			width: 0,
			height: 3
		)
		button.layer.shadowPath = UIBezierPath(
			roundedRect: .init(
				origin: .zero,
				size: .init(
					width: Constants.mapButtonWidth,
					height: Constants.mapButtonWidth
				)
			),
			cornerRadius: Constants.mapButtonWidth / 2
		).cgPath

		button.layer.shadowOpacity = 1
		
		updateButton(button)
		
		return button
	}
	
	private func updateMapButtons() {
		Self.updateButton(zoomInButton)
		Self.updateButton(zoomOutButton)
		Self.updateButton(userLocationButton)
	}
	
	private static func updateButton(_ button: UIButton) {
		button.setBackgroundImage(
			.backgroundImage(
				withColor: .Background.backgroundSecondary,
				size: CGSize(
					width: Constants.mapButtonWidth,
					height: Constants.mapButtonWidth
				)
			).roundedImage,
			for: .normal
		)
		
		button.layer.shadowColor = UIColor.Shadow.shadow.cgColor
	}
	
	@objc func onUserLocationButton() {
		guard let userCoordinate = self.currentPosition?.clLocationCoordinate
		else { return }
		
		animate(
			toLocation: .init(
				latitude: userCoordinate.latitude,
				longitude: userCoordinate.longitude
			),
			with: Constants.defaultZoomLevel
		)
	}
	
	@objc func onZoomInButton() {
		let position = mapView.mapWindow.map.cameraPosition
		animate(
			toLocation: position.target,
			with: position.zoom + 1
		)
	}
	
	@objc func onZoomOutButton() {
		let position = mapView.mapWindow.map.cameraPosition
		animate(
			toLocation: position.target,
			with: position.zoom - 1
		)
	}
	
	private func animate(
		toLocation: YMKPoint,
		with zoomLevel: Float
	) {
		mapView.mapWindow.map.move(
			with: YMKCameraPosition(
				target: toLocation,
				zoom: zoomLevel,
				azimuth: 0,
				tilt: 0
			),
			animationType: YMKAnimation(
				type: YMKAnimationType.smooth,
				duration: 1
			)
		)
	}
	
	@objc private func onKeyboardWillShow() {
		navigationItem.titleView = nil
		if navigationItem.rightBarButtonItem != nil {
			rightBarButton = navigationItem.rightBarButtonItem
			navigationItem.rightBarButtonItem = nil
		}
		(navigationController as? TranslucentNavigationController)?.applyBackground(for: .clear)
		mapOverlayView.alpha = 1
		suggestionsTableView.isHidden = false
		placeSheetStackViewBottomConstraint?.isActive = true
		mapButtonsStackView.alpha = 0
	}
	
	@objc private func onKeyboardWillChangeFrame(_ notification: NSNotification) {
		guard let userInfo = notification.userInfo,
			  let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
		else { return }
		
		placeSheetStackViewBottomConstraint?.constant = -keyboardFrame.height
	}
	
	@objc private func onKeyboardWillHide() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		if let title = input.pickerConfiguration.title {
			navigationItem.titleView = self.createTitleView(
				for: title,
				with: currentUserInterfaceStyle
			)
		}
		
		navigationItem.rightBarButtonItem = rightBarButton
		(navigationController as? TranslucentNavigationController)?.restorePreviousAppearance()
		mapOverlayView.alpha = 0
		suggestionsTableView.isHidden = true
		placeSheetStackViewBottomConstraint?.isActive = false
		mapButtonsStackView.alpha = 1
	}
	
	struct Constants {
		static let defaultZoomLevel: Float = 14
		static let mapButtonWidth: CGFloat = 42
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return geoPlaces.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let geoPlace = self.geoPlaces[safe: indexPath.row]
		else { return UITableViewCell() }
		
		let cell = tableView.dequeueReusableCell(
			AutoEventPlacePickerSuggestionTableCell.id,
			indexPath: indexPath
		)
		
		cell.set(
			title: geoPlace.fullTitle,
			subtitle: geoPlace.infoDescription,
			selected: { [weak self] in
				guard let self
				else { return }
				
				self.handleSelected(geoPlace: self.geoPlaces[safe: indexPath.row])
				
				self.placeInputView.textField.endEditing(true)
			}
		)
		
		return cell
	}
	
	private func handleSelected(position: Coordinate? = nil, geoPlace: GeoPlace? = nil) {
		self.currentGeoPlace = geoPlace
		self.currentPosition = geoPlace?.coordinate
		
		self.placeInputView.textField.text = geoPlace?.infoDescription
		
		self.selectionKind = .geoPlaceSelection
		
		if let coordinate = self.currentPosition {
			let targetPoint = YMKPoint(
				latitude: coordinate.latitude,
				longitude: coordinate.longitude
			)
			
			self.updateLocationPin(
				on: self.mapView.mapWindow.map,
				with: targetPoint
			)
			
			self.animate(toLocation: targetPoint, with: Constants.defaultZoomLevel)
		}
	}
		
	// MARK: - GeoLocation
	enum SelectionKind {
		case mapTap
		case geoPlaceSelection
	}
	
	private var geoLocationAvailabilitySubscription: Subscription?
	private var geoLocationSubscription: Subscription?
	private var currentPosition: Coordinate?
	private var currentGeoPlace: GeoPlace?
	private var selectionKind: SelectionKind?
	
	private var geoPlaces: [GeoPlace] = [] {
		didSet {
			suggestionsTableView.reloadData()
		}
	}
	
	private func setupLocationServices() {
		geoLocationService.requestAvailability(always: false)

		geoLocationAvailabilitySubscription = geoLocationService.subscribeForAvailability { [weak self] availability in
			guard let self
			else { return }

			switch availability {
				case .allowedAlways, .allowedWhenInUse:
					break
					
				case .denied, .notDetermined:
					UIHelper.showLocationRequiredAlert(from: self, locationServicesEnabled: true)
					
				case .restricted:
					UIHelper.showLocationRequiredAlert(from: self, locationServicesEnabled: false)
					
			}
		}
		
		geoLocationSubscription = geoLocationService.subscribeForLocation { [weak self] deviceLocation in
			guard let self
			else { return }
			
			self.currentPosition = deviceLocation
		}
	}
		
	private func updateLocation() {
		if let coordinate = self.currentPosition?.clLocationCoordinate {
			animate(toLocation: coordinate, with: Constants.defaultZoomLevel)
		}
	}
	
	private func animate(toLocation: CLLocationCoordinate2D, with zoomLevel: Float? = nil) {
		mapView.mapWindow.map.move(
			with: YMKCameraPosition(
				target: YMKPoint(latitude: toLocation.latitude, longitude: toLocation.longitude),
				zoom: zoomLevel ?? mapView.mapWindow.map.cameraPosition.zoom,
				azimuth: 0,
				tilt: 0
			)
		)
	}
	
	func onMapTap(with map: YMKMap, point: YMKPoint) {
		handleMapPoint(with: map, point: point)
	}
	
	private func handleMapPoint(with map: YMKMap, point: YMKPoint) {
		let targetLocation = Coordinate(latitude: point.latitude, longitude: point.longitude)
		
		self.positionWasManuallySet = true
		self.selectionKind = .mapTap
		
		updateLocationPin(on: map, with: point)
		
		self.geocodeService.reverseGeocode(location: targetLocation) { [weak self] result in
			guard let self
			else { return }

			if case .success(let place) = result {
				placeInputView.textField.text = place?.infoDescription
			}
		}
		
		self.currentPosition = targetLocation
	}
	
	private func updateLocationPin(on map: YMKMap, with point: YMKPoint) {
		guard input.pickerConfiguration.allowMapSelect
		else { return }
		
		map.mapObjects.clear()
		
		map.mapObjects.addPlacemark(
			with: point,
			image: UIImage.Icons.pinLocation
				.resized(scale: 1.5)
				.tintedImage(withColor: .Icons.iconAccent)
				.overlay(with: .Icons.pin.tintedImage(withColor: .Icons.iconContrast))
		)
	}
	
	func onMapLongTap(with map: YMKMap, point: YMKPoint) {}
	
	// MARK: - Input events handlers
	@objc func inputEditingChanged(_ sender: CommonTextField) {
		locationSearch(by: sender.text)
	}
	
	@objc func inputEditingBegin(_ sender: CommonTextField) {
		locationSearch(by: sender.text)
	}
	
	@objc func inputEditingEnd(_ sender: CommonTextField) {
		if sender.text?.isEmpty ?? true {
			self.geoPlaces = []
		}
	}
			
	private func locationSearch(by text: String?) {
		guard let text
		else { return }
		
		input.requestGeoPlaces(text) { geoPlaces in
			self.geoPlaces = geoPlaces
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
}
