//
//  ListInputSearchableWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 12.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ListInputSearchableWidgetView: WidgetView<ListInputSearchableWidgetDTO> {
		private var userInputView: UserSingleLineInputView?
		
		private let pickerConfiguration: SearchableListPickerViewController.PickerConfiguration
		private let items: [ListInputSearchableItemBackendComponent]?
		
		required init(
			block: ListInputSearchableWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.items = block.items
			self.pickerConfiguration = SearchableListPickerViewController.PickerConfiguration(
				title: block.title,
				subtitle: block.subtitle,
				button: block.button,
				searchInputPlaceholder: block.placeholder,
				searchInputText: block.text,
				highlightSearch: true,
				filterBySearchString: true
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
		}
		
		private func setupTapGestureRecognizer() {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
		}
		
		@objc private func viewTap() {
			self.showPicker(with: self.pickerConfiguration)
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			if let userInputView {
				addSubview(userInputView)
				
				userInputView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			}
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
			
			let controllerItems = self.items
			
			viewController.input = .init(
				items: { _, completion in
					completion?(self.searchableListPickerItems())
				},
				pickerConfiguration: configuration
			)
			
			viewController.output = .init(
				selectedItemIndex: { [weak topViewController] itemIndex in
					if let value = self.items?[safe: itemIndex]?.value {
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
		
		private func searchableListPickerItems() -> [SearchableListPickerViewController.Item] {
			guard let items
			else { return [] }
			
			return items.map {
				SearchableListPickerViewController.Item(
					title: nil,
					themedSizedTitle: $0.text,
					text: nil,
					themedSizedText: nil
				)
			}
		}
	}
}
