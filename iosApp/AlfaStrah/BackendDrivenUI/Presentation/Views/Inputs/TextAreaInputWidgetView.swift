//
//  TextAreaInputWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 20.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TextAreaInputWidgetView: WidgetView<TextAreaInputWidgetDTO> {
		private var userInputView: UserMultiLineInputView?
		
		required init(
			block: TextAreaInputWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			self.userInputView = UserMultiLineInputView(
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
				minHeight: block.minHeight,
				inputColmpleted: { text in
					self.replaceFormData(with: text)
				}
			)
			
			if let countChars = block.maxInputLength {
				self.userInputView?.validationRules.append(LengthValidationRule(maxChars: countChars))
			}
			
			setupUI()
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
	}
}
