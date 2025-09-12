//
//  ListPickerViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 10.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import SDWebImage

extension BDUI {
	class ListPickerViewController: ViewController {
		struct PickerConfiguration {
			let title: ThemedSizedTextComponentDTO?
			let subtitle: ThemedSizedTextComponentDTO?
			let placeholder: ThemedSizedTextComponentDTO?
			let button: ButtonWidgetDTO?
			let isMultiSelectAllowed: Bool
		}
		
		class PickerItem: SelectableItem {
			var id: String
			var title: String
			var isSelected: Bool
			var activateUserInput: Bool
			
			init(from: ListInputItemComponentDTO) {
				self.id = from.id ?? ""
				self.title = from.text?.text ?? ""
				self.isSelected = false
				self.activateUserInput = from.value == nil
			}
		}
		
		struct Input {
			let items: [ListInputItemComponentDTO]
			let pickerConfiguration: PickerConfiguration
		}
		
		var input: Input!
		
		struct Output {
			let done: (_ selectedItem: [[String: Any?]]) -> Void
		}
		
		var output: Output!
		
		private lazy var customValueInputView = createCustomValueInputView()
		private lazy var proceedButton = createProceedButton()
		
		private let promptLabel = UILabel()
		
		private lazy var infoViews = createInfoViews()
		
		private var items: [SelectableItem] = []
		
		private var selectedItems: [SelectableItem] { items.filter { $0.isSelected } }
		private var customValue: String { customValueInputView.textField.text ?? "" }
		
		override func viewDidLoad() {
			super.viewDidLoad()
			
			items = input.items.map { PickerItem(from: $0) }
			
			setupUI()
			updateUI()
		}
		
		private func setupUI() {
			// background
			view.backgroundColor = .Background.backgroundContent
			
			// proceed button
			view.addSubview(proceedButton)
			proceedButton.bottomToSuperview(
				offset: -16,
				usingSafeArea: true
			)
			proceedButton.horizontalToSuperview(insets: .horizontal(15))
			proceedButton.height(48)
			
			// scroll
			let scrollView = UIScrollView()
			view.addSubview(scrollView)
			scrollView.horizontalToSuperview()
			scrollView.bottomToTop(of: proceedButton)
			scrollView.contentLayoutGuide.width(to: scrollView)
			
			// stack
			let stackView = UIStackView()
			stackView.axis = .vertical
			stackView.spacing = 12
			scrollView.addSubview(stackView)
			stackView.topToSuperview()
			stackView.edgesToSuperview(
				excluding: .top,
				insets: .uniform(16)
			)
			
			// values stack
			let valuesStackView = UIStackView()
			valuesStackView.axis = .vertical
			stackView.addArrangedSubview(valuesStackView)
			
			// values
			infoViews.forEach { valuesStackView.addArrangedSubview($0) }
			
			// custom value input
			customValueInputView.textField.placeholder = input.pickerConfiguration.placeholder?.text
			stackView.addArrangedSubview(customValueInputView)
			
			// prompt
			if let prompt = input.pickerConfiguration.subtitle {
				promptLabel.numberOfLines = 0
				promptLabel <~ Style.Label.secondaryText
				view.addSubview(promptLabel)
				promptLabel.topToSuperview(
					offset: 16,
					usingSafeArea: true
				)
				promptLabel.horizontalToSuperview(insets: .horizontal(16))
				
				scrollView.topToBottom(
					of: promptLabel,
					offset: 16
				)
			} else {
				scrollView.topToSuperview(
					offset: 16,
					usingSafeArea: true
				)
			}
			
			updateTheme()
		}
		
		private func createProceedButton() -> RoundEdgeButton {
			let proceedButton = RoundEdgeButton()
			proceedButton <~ Style.RoundedButton.primaryButtonLarge
			proceedButton.setTitle(
				NSLocalizedString("common_continue", comment: ""),
				for: .normal
			)
			proceedButton.addTarget(
				self,
				action: #selector(onProceedButton),
				for: .touchUpInside
			)
			return proceedButton
		}
		
		@objc private func onProceedButton() {
			let selectedItems = self.input.items.filter { item -> Bool in
				self.items.contains(where: { $0.id == item.id && $0.isSelected })
			}
			
			let selectedItemsBody: [[String: Any?]] = selectedItems.compactMap {
				return [
					"selectedValue": [
						"id": $0.id,
						"value": $0.value
					],
					"customValue": { selectedItem -> Any? in
						return self.items.first(where: { $0.id == selectedItem.id })?.activateUserInput ?? false
						? customValue
						: nil
					}($0)
				]
			}
			
			output.done(selectedItemsBody)
		}
		
		private func createInfoViews() -> [SelectedListRowView] {
			return items.enumerated().map { index, item in
				return createInfoView(
					text: input.items[safe: index]?.text,
					with: item,
					showSeparator: index < items.count - 1
				)
			}
		}
		
		private func createInfoView(
			text: ThemedSizedTextComponentDTO?,
			with item: SelectableItem,
			showSeparator: Bool
		) -> SelectedListRowView {
			let view = SelectedListRowView()
			
			view.set(
				text: text,
				isSelected: item.isSelected,
				margins: Style.Margins.defaultInsets,
				showSeparator: showSeparator
			)
			
			view.tapHandler = { [weak self] in
				guard let self
				else { return }
				
				if input.pickerConfiguration.isMultiSelectAllowed {
					tapHandlerWithMultiSelect(
						view,
						with: item
					)
				} else {
					tapHandlerWithoutMultiSelect(
						view,
						with: item
					)
				}
			}
			
			view.height(54)
			
			return view
		}
		
		private func tapHandlerWithMultiSelect(
			_ view: SelectedListRowView,
			with item: SelectableItem
		) {
			guard let index = items.firstIndex(where: { $0.id == item.id })
			else { return }
			
			let isSelected = !items[index].isSelected
			items[index].isSelected = isSelected
			view.update(isSelected: isSelected)
			updateUI()
		}
		
		private func tapHandlerWithoutMultiSelect(
			_ view: SelectedListRowView,
			with item: SelectableItem
		) {
			infoViews.forEach { $0.update(isSelected: false) }
			
			for index in items.indices {
				items[index].isSelected = false
			}
			
			if let index = items.firstIndex(where: { $0.id == item.id }) {
				items[index].isSelected = true
				view.update(isSelected: true)
				updateUI()
			}
		}
		
		private func createCustomValueInputView() -> CommonTextInput {
			let customInputView = CommonTextInput()
			customInputView.shoudValidate = false
			customInputView.textField.rightViewKind = .clearButton
			customInputView.textField.addTarget(
				self,
				action: #selector(onCustomValueInputEditingChanged),
				for: .editingChanged
			)
			return customInputView
		}
		
		@objc private func onCustomValueInputEditingChanged() {
			updateUI()
		}
		
		private func updateUI() {
			proceedButton.isEnabled = !selectedItems.isEmpty
			&& (!selectedItems.contains { $0.activateUserInput } || !customValue.isEmpty)
			
			customValueInputView.isHidden = !items.contains { $0.activateUserInput && $0.isSelected }
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let title = input.pickerConfiguration.title {
				navigationItem.titleView = self.createTitleView(
					for: title,
					with: currentUserInterfaceStyle
				)
			}
			
			if let subtitle = input.pickerConfiguration.subtitle {
				promptLabel <~ StyleExtension.Label(subtitle, for: currentUserInterfaceStyle)
			}
			
			if let button = input.pickerConfiguration.button {
				proceedButton <~ Style.RoundedButton.RoundedParameterizedButton(
					textColor: button.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle),
					backgroundColor: button.themedBackgroundColor?.color(for: currentUserInterfaceStyle),
					borderColor: button.themedBorderColor?.color(for: currentUserInterfaceStyle)
				)
				
				SDWebImageManager.shared.loadImage(
					with: button.leftThemedIcon?.url(for: currentUserInterfaceStyle),
					options: .highPriority,
					progress: nil,
					completed: { image, _, _, _, _, _ in
						self.proceedButton.setImage(image?.resized(newWidth: 20), for: .normal)
					}
				)
			}
		}
		
		private func createTitleView(
			for title: ThemedSizedTextComponentDTO,
			with userInterfaceStyle: UIUserInterfaceStyle
		) -> UIView {
			let titleStackView = UIStackView()
			
			titleStackView.alignment = .center
			titleStackView.axis = .vertical
			titleStackView.distribution = .fill
			titleStackView.spacing = 2
			
			let titleLabel = UILabel()
			titleLabel <~ StyleExtension.Label(title, for: userInterfaceStyle)
			
			titleStackView.addArrangedSubview(titleLabel)
			
			return titleStackView
		}
	}
}
