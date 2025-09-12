//
//  TextHeaderLeftInputWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 22.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TextHeaderLeftInputWidgetView: WidgetView<TextHeaderLeftInputWidgetDTO> {
		private var userInputView: UserSingleLineInputView?
		
		required init(
			block: TextHeaderLeftInputWidgetDTO,
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
				style: .leftAligned,
				inputCompleted: { text in
					self.replaceFormData(with: text)
				}
			)
						
			if let countChars = block.maxInputLength {
				self.userInputView?.validationRules.append(LengthValidationRule(countChars: countChars))
			}
			
			setupUI()
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
