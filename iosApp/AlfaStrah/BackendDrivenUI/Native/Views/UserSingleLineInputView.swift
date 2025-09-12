//
//  UserOnelineInputView.swift
//  AlfaStrah
//
//  Created by vit on 19.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints

extension BDUI {
	
	class UserSingleLineInputView: UIView {
		private let floatingTitle: ThemedSizedTextComponentDTO?
		private let text: ThemedSizedTextComponentDTO?
		private let placeholder: ThemedSizedTextComponentDTO?
		private let error: ThemedSizedTextComponentDTO?
		private let themedBackgroundColor: ThemedValueComponentDTO?
		private let focusedBorderColor: ThemedValueComponentDTO?
		private let errorBorderColor: ThemedValueComponentDTO?
		private let accessoryThemedColor: ThemedValueComponentDTO?
		
		private let inputCompleted: ((String?) -> Void)?
		
		private let isEnabled: Bool
		
		var textField: TextInputBDUI
		
		private let inputStatusLabel = UILabel()
		
		private lazy var textFieldBottomConstraint: Constraint = {
			return textField.bottomToSuperview()
		}()
		
		private lazy var inputStatusLabelConstraints: [Constraint] = [
			inputStatusLabel.topToBottom(of: textField, offset: 6),
			inputStatusLabel.leadingToSuperview(),
			inputStatusLabel.trailingToSuperview(),
			inputStatusLabel.bottomToSuperview()
		]
		
		var validationRules: [ValidationRule] = []
		
		var shoudValidate = true
		var validateAsYouType = true
		var shouldShowValidateStateAsYouType = true
		
		var isValid = true
		
		var showErrorState = true
		
		private var isEditing = false
		
		private func validate() {
			isValid = true
			
			guard shoudValidate
			else { return }
			
			for rule in validationRules {
				switch rule.validate(textField.text ?? "") {
					case .success:
						continue
					case .failure(let error):
						if let error = self.error {
							let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
							
							let attributedText = NSMutableAttributedString(string: "")
							attributedText <~ BDUI.StyleExtension.AttributedString(error, for: currentUserInterfaceStyle)
							
							inputStatusLabel.attributedText = attributedText
						}
						isValid = false
						return
				}
			}
		}
		
		private var style: Appearance = .common
		
		required init(
			floatingTitle: ThemedSizedTextComponentDTO?,
			text: ThemedSizedTextComponentDTO?,
			placeholder: ThemedSizedTextComponentDTO?,
			error: ThemedSizedTextComponentDTO?,
			themedBackgroundColor: ThemedValueComponentDTO?,
			isEnabled: Bool = false,
			focusedBorderColor: ThemedValueComponentDTO?,
			errorBorderColor: ThemedValueComponentDTO?,
			accessoryThemedColor: ThemedValueComponentDTO?,
			style: Appearance = .common,
			inputCompleted: ((String?) -> Void)?
		) {
			self.floatingTitle = floatingTitle
			self.text = text
			self.placeholder = placeholder
			self.error = error
			self.themedBackgroundColor = themedBackgroundColor
			self.isEnabled = isEnabled
			
			self.focusedBorderColor = focusedBorderColor
			self.errorBorderColor = errorBorderColor
			
			self.accessoryThemedColor = accessoryThemedColor
			
			self.inputCompleted = inputCompleted
			
			let abandonedAppearance = InputAppearanceBDUI(
				borderColor: nil,
				fontColor: self.text?.themedColor,
				backgroundColor: self.themedBackgroundColor
			)
			
			let selectedAppearance = InputAppearanceBDUI(
				borderColor: self.focusedBorderColor,
				fontColor: self.text?.themedColor,
				backgroundColor: self.themedBackgroundColor
			)
			
			let errorAppearance = InputAppearanceBDUI(
				borderColor: self.errorBorderColor,
				fontColor: self.error?.themedColor,
				backgroundColor: self.themedBackgroundColor
			)
			
			switch style {
				case .common:
					self.textField = FloatingTitleTextFieldView(
						style: InputStylesBDUI(
							abandoned: abandonedAppearance,
							selected: selectedAppearance,
							error: errorAppearance,
							accessoryThemedColor: accessoryThemedColor
						)
					)
					
				case .leftAligned:
					self.textField = LeftAlignTitleTextFieldView(
						style: InputStylesBDUI(
							abandoned: abandonedAppearance,
							selected: selectedAppearance,
							error: errorAppearance,
							accessoryThemedColor: accessoryThemedColor
						)
					)
					
				case .security:
					let textField = FloatingTitleTextFieldView(
						style: InputStylesBDUI(
							abandoned: abandonedAppearance,
							selected: selectedAppearance,
							error: errorAppearance,
							accessoryThemedColor: accessoryThemedColor
						)
					)
					
					textField.rightViewKind = .securityButton
					
					self.textField = textField
					
				case .arrowRightAccessory:
					let textField = FloatingTitleTextFieldView(
						style: InputStylesBDUI(
							abandoned: abandonedAppearance,
							selected: selectedAppearance,
							error: errorAppearance,
							accessoryThemedColor: accessoryThemedColor
						)
					)
					
					textField.rightViewKind = .arrowRightButton
					
					self.textField = textField
					
				case .withDeleteButton:
					let textField = FloatingTitleTextFieldView(
						style: InputStylesBDUI(
							abandoned: abandonedAppearance,
							selected: selectedAppearance,
							error: errorAppearance,
							accessoryThemedColor: accessoryThemedColor
						)
					)
					
					textField.rightViewKind = .clearButton
					
					self.textField = textField
			}
			
			super.init(frame: .zero)
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			textField.isEnabled = self.isEnabled
			
			addSubview(textField)
			textField.translatesAutoresizingMaskIntoConstraints = false
			
			addSubview(inputStatusLabel)
			inputStatusLabel.translatesAutoresizingMaskIntoConstraints = false
			inputStatusLabel.numberOfLines = 0
			inputStatusLabel <~ Style.Label.negativeSubhead
			
			textField.topToSuperview()
			textField.horizontalToSuperview()
			textFieldBottomConstraint.isActive = true
			
			textField.addTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
			textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
			textField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: .editingDidEnd)
			
			updateTheme(firstStart: true)
		}
		
		@objc func textFieldEditingDidBegin() {
			textField.appearanceType = .selected
			statusLabel(show: false)
			isEditing = true
		}
		
		@objc func textFieldEditingChanged() {
			if validateAsYouType {
				validate()
				if shouldShowValidateStateAsYouType {
					statusLabel(show: !isValid)
				}
			}
			
			updateTextFieldAppearance(isEditing: true, showErrorState: shouldShowValidateStateAsYouType && showErrorState)
		}
		
		@objc func textFieldEditingDidEnd() {
			forceValidate()
			
			isEditing = false
			
			if shoudValidate {
				if isValid {
					inputCompleted?(textField.attributedText?.string ?? textField.text)
				}
			} else {
				inputCompleted?(textField.attributedText?.string ?? textField.text)
			}
		}
		
		private func forceValidate() {
			validate()
			
			updateTextFieldAppearance(isEditing: false, showErrorState: showErrorState)
			
			if let text = textField.text,
			   text.isEmpty {
				statusLabel(show: false)
			} else if let text = textField.attributedText?.string,
					  text.isEmpty {
				statusLabel(show: false)
			} else {
				statusLabel(show: !isValid)
			}
		}
		
		private func updateTextFieldAppearance(isEditing: Bool, showErrorState: Bool = true) {
			if let text = textField.text,
			   !text.isEmpty {
				textField.appearanceType = isValid
				? isEditing
				? .selected
				: .abandoned
				: showErrorState
				?   (!validateAsYouType && isEditing)
				? .selected
				: .error
				: isEditing
				? textField.appearanceType
				: .abandoned
			} else {
				textField.appearanceType = isValid
				? .abandoned
				: showErrorState
				? isEditing
				? .error
				: .abandoned
				: .abandoned
			}
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme(firstStart: false)
		}
		
		private func updateTheme(firstStart: Bool) {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let floatingTitle = self.floatingTitle {
				let attributedText = NSMutableAttributedString(string: "")
				attributedText <~ BDUI.StyleExtension.AttributedString(
					floatingTitle,
					for: currentUserInterfaceStyle
				)
				
				textField.floatingLabelAttributedText = attributedText
			}
			
			if let blockText = self.text {
				let attributedString = NSMutableAttributedString(string: "")
				
				attributedString <~ BDUI.StyleExtension.AttributedString(
					blockText,
					for: currentUserInterfaceStyle,
					with: {
						return firstStart
						? blockText.text
						: textField.attributedText?.string
					}()
				)
				
				textField.attributedText = attributedString
			}
			
			if let placeholder = self.placeholder {
				let attributedText = NSMutableAttributedString(string: "")
				attributedText <~ BDUI.StyleExtension.AttributedString(placeholder, for: currentUserInterfaceStyle)
				
				textField.attributedPlaceholder = attributedText
			}
		}
		
		private func statusLabel(show: Bool) {
			if show {
				if showErrorState {
					inputStatusLabel.isHidden = false
					
					[textFieldBottomConstraint].deActivate()
					inputStatusLabelConstraints.activate()
				}
			} else {
				inputStatusLabel.isHidden = true
				
				inputStatusLabelConstraints.deActivate()
				[textFieldBottomConstraint].activate()
			}
		}
		
		func error(show: Bool, with text: String = "") {
			inputStatusLabel.text = text
			
			textField.appearanceType = show
			? .error
			: isEditing
			? .selected
			: .abandoned
			
			statusLabel(show: show)
		}
		
		enum Appearance {
			case common
			case security
			case withDeleteButton
			case arrowRightAccessory
			case leftAligned
		}
	}	
}
