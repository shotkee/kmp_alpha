//
//  ListInputWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 11.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ListInputWidgetView: WidgetView<ListInputWidgetDTO> {
		private var userInputView: UserSingleLineInputView?
		
		private let pickerConfiguration: ListPickerViewController.PickerConfiguration
		private let items: [ListInputItemComponentDTO]?
		
		required override init(
			block: ListInputWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.items = block.items
			self.pickerConfiguration = ListPickerViewController.PickerConfiguration(
				title: block.title,
				subtitle: block.subtitle,
				placeholder: block.placeholder,
				button: block.button,
				isMultiSelectAllowed: block.multipleSelection
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
		
		private func showPicker(
			with configuration: ListPickerViewController.PickerConfiguration
		) {
			guard let topViewController = UIHelper.topViewController()
			else { return }
			
			let viewController = ListPickerViewController()
			
			ApplicationFlow.shared.container.resolve(viewController)
			
			let navigationController = RMRNavigationController(rootViewController: viewController)
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			viewController.input = .init(
				items: items ?? [],
				pickerConfiguration: configuration
			)
			
			viewController.output = .init(
				done: { [weak topViewController] selectedItems in
					self.replaceFormData(with: selectedItems)
					
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
	}
}
