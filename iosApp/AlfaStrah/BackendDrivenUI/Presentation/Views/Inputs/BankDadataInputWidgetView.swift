//
//  InputBankDadataWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 17.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BankDadataInputWidgetView: WidgetView<BankDadataInputWidgetDTO>,
									 DmsCostRecoveryServiceDependency {
		var dmsCostRecoveryService: DmsCostRecoveryService!
		
		private var userInputView: UserSingleLineInputView?
		
		private let pickerConfiguration: SearchableListPickerViewController.PickerConfiguration
		
		private var banks: [DmsCostRecoveryBank] = []
		
		required override init(
			block: BankDadataInputWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.pickerConfiguration = SearchableListPickerViewController.PickerConfiguration(
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
				style: .arrowRightAccessory,
				inputCompleted: { _ in }
			)
			
			self.userInputView?.isUserInteractionEnabled = false
			
			setupUI()
			setupTapGestureRecognizer()
			
			ApplicationFlow.shared.container.resolve(self)
		}
		
		private func setupUI() {
			if let userInputView {
				addSubview(userInputView)
				
				userInputView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			}
		}
		
		private func setupTapGestureRecognizer() {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		@objc private func viewTap() {
			self.showPicker(with: self.pickerConfiguration)
		}
		
		private func showPicker(
			with configuration: SearchableListPickerViewController.PickerConfiguration
		) {
			guard let topViewController = UIHelper.topViewController()
			else { return }
			
			let viewController = SearchableListPickerViewController()
			
			ApplicationFlow.shared.container.resolve(viewController)
			
			let navigationController = RMRNavigationController(rootViewController: viewController)
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			viewController.input = .init(
				items: { [weak viewController] searchString, completion in
					guard let searchString,
						  let viewController
					else { return }
					
					self.dmsCostRecoveryService.searchBanks(query: searchString) { [weak viewController] result in
						guard let viewController
						else { return }
						
						switch result {
							case .success(let banks):
								self.banks = banks
								
								viewController.notify.setState(.data)
								
								completion?(
									banks.map {
										return SearchableListPickerViewController.Item(
											title: $0.title,
											themedSizedTitle: nil,
											text: $0.bik,
											themedSizedText: nil
										)
									}
								)
								
							case .failure(let error):
								viewController.notify.setState(.error)
						}
					}
				},
				pickerConfiguration: configuration
			)
			
			viewController.output = .init(
				selectedItemIndex: { [weak topViewController] index in
					if let bank = self.banks[safe: index],
					   let value = (DmsCostRecoveryBankTransformer().transform(destination: bank).value) as? [String: Any] {
						self.replaceFormData(with: value)
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
