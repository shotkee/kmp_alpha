//
//  UserMultiLineInputView.swift
//  AlfaStrah
//
//  Created by vit on 20.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints

extension BDUI {
	class UserMultiLineInputView: UIView, UITextViewDelegate {
		private let floatingTitle: ThemedSizedTextComponentDTO?
		private let text: ThemedSizedTextComponentDTO?
		private let placeholder: ThemedSizedTextComponentDTO?
		private let error: ThemedSizedTextComponentDTO?
		private let themedBackgroundColor: ThemedValueComponentDTO?
		private let focusedBorderColor: ThemedValueComponentDTO?
		private let errorBorderColor: ThemedValueComponentDTO?
		
		private let minHeight: CGFloat?
		
		private let inputColmpleted: ((String?) -> Void)?
		
		private let isEnabled: Bool
		
		let textAreaView: TextAreaView
		private let inputStatusLabel = UILabel()
		
		private lazy var textAreaViewBottomConstraint: Constraint = {
			return textAreaView.bottomToSuperview()
		}()
		
		private lazy var inputStatusLabelConstraints: [Constraint] = [
			inputStatusLabel.topToBottom(of: textAreaView, offset: 6),
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
				switch rule.validate(textAreaView.text ?? "") {
					case .success:
						continue
					case .failure(let error):
						inputStatusLabel.text = error.localizedDescription
						isValid = false
						return
				}
			}
		}
		
		required init(
			floatingTitle: ThemedSizedTextComponentDTO?,
			text: ThemedSizedTextComponentDTO?,
			placeholder: ThemedSizedTextComponentDTO?,
			error: ThemedSizedTextComponentDTO?,
			themedBackgroundColor: ThemedValueComponentDTO?,
			isEnabled: Bool = false,
			focusedBorderColor: ThemedValueComponentDTO?,
			errorBorderColor: ThemedValueComponentDTO?,
			minHeight: CGFloat?,
			inputColmpleted: ((String?) -> Void)?
		) {
			self.floatingTitle = floatingTitle
			self.text = text
			self.placeholder = placeholder
			self.error = error
			self.themedBackgroundColor = themedBackgroundColor
			self.isEnabled = isEnabled
			
			self.focusedBorderColor = focusedBorderColor
			self.errorBorderColor = errorBorderColor
			
			self.minHeight = minHeight
			
			let abandonedAppearance = TextAreaView.Appearance(
				borderColor: nil,
				fontColor: self.text?.themedColor,
				backgroundColor: self.themedBackgroundColor
			)
			
			let selectedAppearance = TextAreaView.Appearance(
				borderColor: self.focusedBorderColor,
				fontColor: self.text?.themedColor,
				backgroundColor: self.themedBackgroundColor
			)
			
			let errorAppearance = TextAreaView.Appearance(
				borderColor: self.errorBorderColor,
				fontColor: self.error?.themedColor,
				backgroundColor: self.themedBackgroundColor
			)
			
			let floatingAppearance = TextAreaView.Appearance(
				borderColor: nil,
				fontColor: self.floatingTitle?.themedColor,
				backgroundColor: nil
			)
			
			self.textAreaView = TextAreaView(
				style: TextAreaView.Styles(
					abandoned: abandonedAppearance,
					selected: selectedAppearance,
					error: errorAppearance,
					floating: floatingAppearance
				)
			)
			
			self.inputColmpleted = inputColmpleted
			
			super.init(frame: .zero)
			
			textAreaView.delegate = self
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			textAreaView.isEditable = self.isEnabled
			
			addSubview(textAreaView)
			textAreaView.translatesAutoresizingMaskIntoConstraints = false
			textAreaView.isScrollEnabled = false
			
			addSubview(inputStatusLabel)
			inputStatusLabel.translatesAutoresizingMaskIntoConstraints = false
			inputStatusLabel.numberOfLines = 0
			inputStatusLabel <~ Style.Label.negativeSubhead
			
			textAreaView.topToSuperview()
			textAreaView.horizontalToSuperview()
			
			if let minHeight = self.minHeight {
				textAreaView.height(min: minHeight)
			}
			
			textAreaViewBottomConstraint.isActive = true
			
			updateTheme(firstStart: true)
		}
		
		// MARK: - UITextViewDelegate
		func textViewDidBeginEditing(_ textView: UITextView) {
			textAreaView.appearanceType = .selected
			
			statusLabel(show: false)
			
			isEditing = true
		}
		
		func textViewDidChange(_ textView: UITextView) {
			if validateAsYouType {
				validate()
				if shouldShowValidateStateAsYouType {
					statusLabel(show: !isValid)
				}
			}
			
			updateTextFieldAppearance(isEditing: true, showErrorState: shouldShowValidateStateAsYouType && showErrorState)
		}
		
		func textViewDidEndEditing(_ textView: UITextView) {
			forceValidate()
			
			isEditing = false
			
			inputColmpleted?(textAreaView.attributedText?.string ?? textAreaView.text)
		}
		
		private func forceValidate() {
			validate()
			
			updateTextFieldAppearance(isEditing: false, showErrorState: showErrorState)
			
			if let text = textAreaView.text,
			   text.isEmpty {
				statusLabel(show: false)
			} else {
				statusLabel(show: !isValid)
			}
		}
		
		private func updateTextFieldAppearance(isEditing: Bool, showErrorState: Bool = true) {
			if let text = textAreaView.text,
			   !text.isEmpty {
				textAreaView.appearanceType = isValid
				? isEditing
				? .selected
				: .abandoned
				: showErrorState
				?   (!validateAsYouType && isEditing)
				? .selected
				: .error
				: isEditing
				? textAreaView.appearanceType
				: .abandoned
			} else {
				textAreaView.appearanceType = isValid
				? .abandoned
				: showErrorState
				? isEditing
				? .error
				: .abandoned
				: .abandoned
			}
		}
		
		// MARK: - Dark theme support
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme(firstStart: false)
		}
		
		private func updateTheme(firstStart: Bool) {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let floatingTitle = self.floatingTitle {
				let attributedText = NSMutableAttributedString(string: "")
				attributedText <~ BDUI.StyleExtension.AttributedString(floatingTitle, for: currentUserInterfaceStyle)
				
				textAreaView.floatingLabelAttributedText = attributedText
			}
			
			if let blockText = self.text,
			   !(blockText.text?.isEmpty ?? true) {
				let attributedString = NSMutableAttributedString(string: "")
				
				attributedString <~ StyleExtension.AttributedString(
					blockText,
					for: currentUserInterfaceStyle,
					with: {
						return firstStart
						? blockText.text
						: textAreaView.attributedText?.string
					}()
				)
				
				textAreaView.attributedText = attributedString
			}
			
			if let placeholder = self.placeholder {
				let attributedText = NSMutableAttributedString(string: "")
				attributedText <~ StyleExtension.AttributedString(placeholder, for: currentUserInterfaceStyle)
				
				textAreaView.attributedPlaceholder = attributedText
			}
		}
		
		// MARK: - Error state handle
		private func statusLabel(show: Bool) {
			if show {
				if showErrorState {
					inputStatusLabel.isHidden = false
					
					textAreaViewBottomConstraint.isActive = false
					inputStatusLabelConstraints.activate()
				}
			} else {
				inputStatusLabel.isHidden = true
				
				inputStatusLabelConstraints.deActivate()
				textAreaViewBottomConstraint.isActive = true
			}
		}
		
		func error(show: Bool, with text: String = "") {
			inputStatusLabel.text = text
			
			textAreaView.appearanceType = show
			? .error
			: isEditing
			? .selected
			: .abandoned
			
			statusLabel(show: show)
		}
	}
}
