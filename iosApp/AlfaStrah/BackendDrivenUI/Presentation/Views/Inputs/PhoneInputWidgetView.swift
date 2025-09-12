//
//  PhoneInputWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 20.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class PhoneInputWidgetView: WidgetView<PhoneInputWidgetDTO> {
		private var userInputView: UserSingleLineInputView?
		
		private let phoneFormatter = PhoneNumberFormatter(predefinedAreaCode: 7, maxNumberLength: 10)
		
		private lazy var textFieldController: TextFieldController = TextFieldController(
			textField: self.userInputView?.textField,
			asYouTypeFormatter: phoneFormatter
		)
		
		required init(
			block: PhoneInputWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
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
				inputCompleted: { _ in
					self.replaceFormData(with: self.textFieldController.unformattedString)
				}
			)
			
			if let countChars = block.maxInputLength {
				self.userInputView?.validationRules.append(LengthValidationRule(countChars: countChars))
			}
			
			self.userInputView?.validationRules.append(LengthValidationRule(countChars: 18))
			
			self.userInputView?.validateAsYouType = false
			self.userInputView?.textField.keyboardType = .phonePad
			self.userInputView?.textField.addTarget(self, action: #selector(phoneInputEditingDidEnd), for: .editingDidEnd)
			self.userInputView?.textField.addTarget(self, action: #selector(phoneInputAllEditingEvents), for: .allEditingEvents)
			
			setupUI()
			
			updateFormattedText()
		}
		
		@objc func phoneInputEditingDidEnd() {
			// valiadate phone input if needed
		}
		
		@objc func phoneInputAllEditingEvents() {
			_ = textFieldController.formattedString(from: textFieldController.unformattedString)
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
		
		private func updateFormattedText() {
			if let unformattedString = self.userInputView?.textField.text {
				self.userInputView?.textField.text = phoneFormatter.format(
					existing: unformattedString,
					input: unformattedString,
					range: NSRange(location: 0, length: unformattedString.count)
				).string
			}
		}
	}
}
