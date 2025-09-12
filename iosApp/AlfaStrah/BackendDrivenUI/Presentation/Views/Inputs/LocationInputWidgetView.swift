//
//  LocationInputWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 27.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LocationInputWidgetView: WidgetView<LocationInputWidgetDTO>,
								   GeocodeServiceDependency {
		var geocodeService: GeocodeService!
		
		private var userInputView: UserSingleLineInputView?
		
		private let pickerConfigurationWithMap: AutoEventPlacePickerViewController.PickerConfiguration
		private let pickerConfigurationWithoutMap: SearchableListPickerViewController.PickerConfiguration
		
		required init(
			block: LocationInputWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.pickerConfigurationWithMap = AutoEventPlacePickerViewController.PickerConfiguration(
				title: block.title,
				modalTitle: block.modalTitle,
				subtitle: block.subtitle,
				button: block.button,
				allowMapSelect: block.allowMapSelect
			)
			
			self.pickerConfigurationWithoutMap = SearchableListPickerViewController.PickerConfiguration(
				title: block.title,
				subtitle: block.subtitle,
				button: block.button,
				searchInputPlaceholder: block.placeholder,
				searchInputText: block.text,
				highlightSearch: false,
				filterBySearchString: false
			)
			
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			self.userInputView = UserSingleLineInputView(
				floatingTitle: block.floatingTitle,
				text: block.text,
				placeholder: block.placeholder,
				error: block.error,
				themedBackgroundColor: block.themedBackgroundColor,
				isEnabled: {
					switch block.state {
						case .normal:
							return true
						case .disabled:
							return false
					}
				}(),
				focusedBorderColor: block.focusedBorderColor,
				errorBorderColor: block.errorBorderColor,
				accessoryThemedColor: block.arrow?.themedColor,
				inputCompleted: { _ in }
			)
			
			self.userInputView?.isUserInteractionEnabled = false
			
			setupUI()
			
			setupTapGestureRecognizer()
			
			ApplicationFlow.shared.container.resolve(self)
		}
		
		private func setupTapGestureRecognizer() {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
		}
		
		@objc private func viewTap() {
			guard let formDataValue = block.formData?.value as? [String: Any]
			else { return }
			
			if block.allowMapSelect {
				self.showPickerWithMap(with: self.pickerConfigurationWithMap, formDataValue: formDataValue)
			} else {
				self.showPickerWithoutMap(with: self.pickerConfigurationWithoutMap)
			}
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			if let userInputView {
				addSubview(userInputView)
				
				userInputView.edgesToSuperview(
					insets: UIEdgeInsets(
						top: 0,
						left: self.horizontalInset,
						bottom: 0,
						right: self.horizontalInset
					)
				)
			}
		}
		
		private func showPickerWithMap(
			with configuration: AutoEventPlacePickerViewController.PickerConfiguration,
			formDataValue: [String: Any]?
		) {
			guard let topViewController = UIHelper.topViewController()
			else { return }
			
			let viewController = AutoEventPlacePickerViewController()
			
			ApplicationFlow.shared.container.resolve(viewController)
			
			let navigationController = TranslucentNavigationController(rootViewController: viewController)
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			navigationController.navigationBar.isTranslucent = true
			
			viewController.input = .init(
				pickerConfiguration: configuration,
				initialGeoPlace: {
					if let formDataValue = self.block.formData?.value as? [String: Any],
					   let geoPlaceDict = formDataValue["geoPlace"] as? [String: Any] {
						return GeoPlaceTransformer().transform(source: geoPlaceDict).value
					}
					
					return nil
				}(),
				initialPosition: {
					if let formDataValue = self.block.formData?.value as? [String: Any],
					   let body = formDataValue["coordinate"] as? [String: Any] {
						return CoordinateTransformer().transform(source: body).value
					}
					
					return nil
				}(),
				requestGeoPlaces: { [weak viewController] text, completion in
					guard let viewController
					else { return }
					
					self.cancellable = CancellableNetworkTaskContainer()
					
					if text.isEmpty {
						self.cancellable?.cancel()
						completion([])
					}
					
					let task = self.geocodeService.searchLocationDictionaries(
						text,
						flowType: nil
					) { [weak self] result in
						guard let self
						else { return }
						
						switch result {
							case .success(let dictionaries):
								self.formDataDictionaries = dictionaries
								
								let geoPlaces = dictionaries.compactMap { GeoPlaceTransformer().transform(source: $0).value }
								completion(geoPlaces)
								
							case .failure(let error):
								ErrorHelper.show(error: error, alertPresenter: viewController.alertPresenter)
						}
					}
					
					self.cancellable?.addCancellables([ task ])
				}
			)
			
			viewController.output = .init(
				positionSelected: { [weak topViewController] coordinate in
					var body: [String: Any] = [:]
					
					body["coordinate"] = (CoordinateTransformer().transform(destination: coordinate).value) as? [String: Any]
					
					self.replaceFormData(with: body)
					topViewController?.dismiss(animated: true)
				},
				locationSelected: { [weak topViewController] index in
					var body: [String: Any] = [:]
					
					if let dict = self.formDataDictionaries[safe: index] {
						body["geoPlace"] = dict
						
						self.replaceFormData(with: body)
						topViewController?.dismiss(animated: true)
					}
				}
			)
			
			viewController.addCloseButton(position: .right) { [weak topViewController] in
				topViewController?.dismiss(animated: true)
			}
			
			topViewController.present(
				navigationController,
				animated: true
			)
		}
		
		private var places: [GeoPlace] = []
		private var formDataDictionaries: [[String: Any]] = []
		private var cancellable: CancellableNetworkTaskContainer?
		
		private func showPickerWithoutMap(
			with configuration: SearchableListPickerViewController.PickerConfiguration
		) {
			guard let topViewController = UIHelper.topViewController()
			else { return }
			
			let viewController = SearchableListPickerViewController()
			
			ApplicationFlow.shared.container.resolve(viewController)
			
			let navigationController = RMRNavigationController(rootViewController: viewController)
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			viewController.input = .init(
				items: { searchString, completion in
					guard let searchString,
						  searchString.count > 3
					else { return }
					
					self.cancellable = CancellableNetworkTaskContainer()
					
					let task = self.geocodeService.searchLocationDictionaries(
						searchString,
						flowType: nil
					) { [weak viewController] result in
						guard let viewController
						else { return }
						
						switch result {
							case .success(let dictionaries):
								viewController.notify.setState(.data)
								self.formDataDictionaries = dictionaries
								
								self.places = dictionaries.compactMap { GeoPlaceTransformer().transform(source: $0).value }
								
								completion?(
									self.places.map {
										return SearchableListPickerViewController.Item(
											title: $0.title,
											themedSizedTitle: nil,
											text: $0.description,
											themedSizedText: nil
										)
									}
								)
								
							case .failure(let error):
								viewController.notify.setState(.error)
								
						}
					}
					
					self.cancellable?.addCancellables([ task ])
				},
				pickerConfiguration: configuration
			)
			
			viewController.output = .init(
				selectedItemIndex: { [weak topViewController] itemIndex in
					var body: [String: Any] = [:]
					
					if let selectedDictionary = self.formDataDictionaries[safe: itemIndex] {
						body["geoPlace"] = selectedDictionary
						
						self.replaceFormData(with: body)
					}
					
					topViewController?.dismiss(animated: true)
				}
			)
			
			viewController.addCloseButton(position: .right) { [weak topViewController] in
				topViewController?.dismiss(animated: true)
			}
			
			topViewController.present(
				navigationController,
				animated: true
			)
		}
	}
}
