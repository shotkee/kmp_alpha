//
//  EmailAndCodeInputsViewController.swift
//  AlfaStrah
//
//  Created by Илья Матвеев on 13.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import TinyConstraints

class EmailAndCodeInputsViewController: ViewController, UITextFieldDelegate {
	private let continueButton = RoundEdgeButton()
	private let rootStackView = UIStackView()
	private var smsCodeInput = CommonTextInput()
	private var emailCodeInput = CommonTextInput()
	private var emailCodeInputBackground = UIView()
	private var repeatSmsButton = RoundEdgeButton()
	private var repeatEmailButton = RoundEdgeButton()
	private let errorInfoTitleLabel = UILabel()
	private let errorBackgroundView = UIView()
	private let chatTransitionTextView = LinkedTextView()
	private var scrollView = UIScrollView()
	
	private var buttonBottomConstraint = Constraint()
	private var buttonTopConstraint = Constraint()
	
	private let timeFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [ .minute, .second ]
		formatter.zeroFormattingBehavior = [ .pad ]
		return formatter
	}()
	
	static var resendSmsTimerDuration: TimeInterval = 0.0
	static var resendEmailTimerDuration: TimeInterval = 0.0
	
	private enum InputType {
		case sms
		case email
	}
	
	struct Output {
		let openChat: () -> Void
		let resendSms: () -> Void
		let resendEmailCode: () -> Void
		let validationPassed: (_ emailCode: String, _ smsCode: String) -> Void
	}
	
	struct Input {
		let phoneNumber: String
		let email: String
		var resendSmsCodeTimer: TimeInterval
		var resendEmailCodeTimer: TimeInterval
	}

	var input: Input!
	var output: Output!

	private var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd.MM.yyyy"
		return dateFormatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
				
		title = NSLocalizedString("forgotten_password_title", comment: "")
		
		view.backgroundColor = .Background.backgroundContent
		
		view.addSubview(scrollView)
		scrollView.edgesToSuperview()
				
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		
		setupRootStackView()
		setupContinueButton()

		setupCardSection(
			title: "Введите код из СМС.",
			dataForSend: input.phoneNumber.maskedPhoneString(2),
			type: .sms
		)

		setupCardSection(
			title: "Введите код из email.",
			dataForSend: input.email.maskedEmailString(maxNameLength: 5, maxDomainLength: 9),
			type: .email
		)

		setupErrorInfoView()
		setupChatTransitionTextView()
		
		addRightButton(title: NSLocalizedString("auth_sign_up_chat_nav_item_title", comment: ""), action: output.openChat)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {

		guard let userInfo = notification.userInfo,
			  let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
		else { return }

		let frameInView = view.convert(keyboardFrame, from: nil)

		var contentInset = scrollView.contentInset
		contentInset.bottom = (UIScreen.main.bounds.height - frameInView.origin.y) + 20
		scrollView.contentInset = contentInset
	}

	@objc func keyboardWillHide(notification: NSNotification) {

		let contentInset = UIEdgeInsets.zero
		scrollView.contentInset = contentInset
	}
	
	private func setupRootStackView() {
		scrollView.addSubview(rootStackView)
		rootStackView.backgroundColor = .clear
		rootStackView.width(to: scrollView)
		rootStackView.edgesToSuperview(excluding: .top)
		rootStackView.topToSuperview(offset: 20)
		scrollView.bounces = true
		scrollView.alwaysBounceVertical = true
		
		rootStackView.distribution = .fill
		rootStackView.alignment = .center
		rootStackView.axis = .vertical
		rootStackView.spacing = 8
	}
	
	private func setupErrorInfoView() {
		errorBackgroundView.backgroundColor = .clear
		rootStackView.addArrangedSubview(errorBackgroundView)
		let errorInfoView = UIView()
		errorInfoView.backgroundColor = .Background.backgroundNegativeTint
		errorInfoView.layer.cornerRadius = 10
		errorBackgroundView.width(to: emailCodeInputBackground)
		errorBackgroundView.isHidden = true
		
		errorBackgroundView.addSubview(errorInfoView)
		errorInfoView.horizontalToSuperview()
		errorInfoView.verticalToSuperview(insets: .vertical(10))

		let errorInfoIconImageView = UIImageView()
		errorInfoView.addSubview(errorInfoIconImageView)
		errorInfoIconImageView.topToSuperview(offset: 12)
		errorInfoIconImageView.leadingToSuperview(offset: 12)
		errorInfoIconImageView.height(18)
		errorInfoIconImageView.aspectRatio(1)
		errorInfoIconImageView.image = .Icons.info.tintedImage(withColor: .Icons.iconAccent)
		
		errorInfoView.addSubview(errorInfoTitleLabel)
		errorInfoTitleLabel.verticalToSuperview(insets: .vertical(12))
		errorInfoTitleLabel.numberOfLines = 0
		errorInfoTitleLabel.trailingToSuperview(offset: 12)
		errorInfoTitleLabel.leadingToTrailing(of: errorInfoIconImageView, offset: 8)
		errorInfoTitleLabel <~ Style.Label.primarySubhead

		hideErrors()
	}
	
	private func setupChatTransitionTextView() {
		chatTransitionTextView.backgroundColor = .clear
		chatTransitionTextView.translatesAutoresizingMaskIntoConstraints = false
		chatTransitionTextView.textContainerInset = .zero
		
		let link = LinkArea(
			text: NSLocalizedString("email_and_code_validation_link_text", comment: ""),
			link: nil,
			tapHandler: { [weak self] _ in
				self?.output.openChat()
			}
		)

		chatTransitionTextView.set(
			text: NSLocalizedString("email_and_code_validation_chat", comment: ""),
			userInteractionWithTextEnabled: true,
			links: [ link ],
			linkColor: .Text.textPrimary
		)

		chatTransitionTextView.textAlignment = .center

		view.addSubview(chatTransitionTextView)
		chatTransitionTextView.horizontalToSuperview(insets: .horizontal(18))
		chatTransitionTextView.centerXToSuperview()
		chatTransitionTextView.bottomToTop(of: continueButton, offset: -15)
	}
	
	private func setupCardSection(title: String, dataForSend: String, type: InputType) {
		let whiteBackground = UIView()
		whiteBackground.backgroundColor = .Background.backgroundSecondary
		
		let stackView = UIStackView()
		stackView.distribution = .fill
		stackView.alignment = .leading
		stackView.axis = .vertical
		stackView.spacing = 10
		
		whiteBackground.addSubview(stackView)
		
		let titleLabel = UILabel()
		titleLabel.numberOfLines = 1
		titleLabel.text = title
		titleLabel <~ Style.Label.primaryText
		
		let descriptionLabel = UILabel()
		descriptionLabel.numberOfLines = 1
		let descriptionText = (
			(NSLocalizedString("email_and_code_validation_send_to", comment: "") + dataForSend) <~ Style.TextAttributes.primaryText
		).mutable
		let rangeOfData = NSString(string: descriptionText.string).range(of: dataForSend)
		descriptionText.addAttributes(Style.TextAttributes.accentThemedText, range: rangeOfData)
		descriptionLabel.attributedText = descriptionText

		let labelsStackView = UIStackView()
		labelsStackView.distribution = .fill
		labelsStackView.alignment = .fill
		labelsStackView.axis = .vertical
		
		labelsStackView.addArrangedSubview(titleLabel)
		labelsStackView.addArrangedSubview(descriptionLabel)
		
		stackView.addArrangedSubview(labelsStackView)
		
		let codeInput = CommonTextInput()
		codeInput.textField.placeholder = NSLocalizedString("email_and_code_validation_placeholder", comment: "")
		codeInput.isValid = false
		codeInput.textField.keyboardType = .numberPad
		codeInput.textField.addTarget(self, action: #selector(allInputEvents), for: .allEditingEvents)
		codeInput.textField.addTarget(self, action: #selector(inputEventsEnd), for: .editingDidEnd)
		codeInput.validationRules = [
			LengthValidationRule(countChars: Constants.maxCodeLenght)
		]
		codeInput.textField.delegate = self

		stackView.addArrangedSubview(codeInput)
		codeInput.horizontalToSuperview(insets: .horizontal(15))

		let repeatButton = RoundEdgeButton()
		stackView.addArrangedSubview(repeatButton)

		repeatButton <~ Style.RoundedButton.redBackground
		repeatButton.setTitle(NSLocalizedString("email_and_code_validation_resend_again", comment: ""), for: .normal)
		repeatButton.topToBottom(of: codeInput, offset: 15)
		repeatButton.height(32)
		repeatButton.horizontalToSuperview(insets: .horizontal(40))
	   
		switch type {
			case .email:
				emailCodeInput = codeInput
				codeInput.textField.addTarget(self, action: #selector(emailInputEventsBegin), for: .editingDidBegin)
				repeatButton.addTarget(self, action: #selector(resendEmailCode), for: .touchUpInside)
				repeatEmailButton = repeatButton
				
			case .sms:
				smsCodeInput = codeInput
				codeInput.textField.addTarget(self, action: #selector(smsInputEventsBegin), for: .editingDidBegin)
				smsCodeInput.textField.textContentType = .oneTimeCode
				repeatButton.addTarget(self, action: #selector(resendSmsCode), for: .touchUpInside)
				repeatSmsButton = repeatButton
		}
		
		let cardView = CardView(contentView: whiteBackground)
		cardView.contentColor = .Background.backgroundSecondary
		cardView.highlightedColor = .Background.backgroundSecondary
		stackView.edgesToSuperview(insets: TinyEdgeInsets(top: 20, left: 15, bottom: 20, right: 15))
		rootStackView.addArrangedSubview(cardView)
		cardView.horizontalToSuperview(insets: .horizontal(16))
		emailCodeInputBackground = cardView
		
		buttonTopConstraint = continueButton.topToBottom(of: cardView, offset: 18)
		buttonTopConstraint.isActive = false
	}
	
	func smsCodeResended(resendSmsCodeTimer: TimeInterval) {
		input.resendSmsCodeTimer = resendSmsCodeTimer
		startResendTimer(type: .sms)
	}
	
	func emailCodeResended(resendEmailCodeTimer: TimeInterval) {
		input.resendEmailCodeTimer = resendEmailCodeTimer
		startResendTimer(type: .email)
	}

	@objc func resendSmsCode() {
		hideErrors()
		errorBackgroundView.isHidden = true
		repeatSmsButton.isEnabled = false
		
		output.resendSms()
		startResendTimer(type: .sms)
	}
	
	@objc func resendEmailCode() {
		hideErrors()
		errorBackgroundView.isHidden = true
		repeatEmailButton.isEnabled = false
		
		output.resendEmailCode()
		startResendTimer(type: .email)
	}
	
	// using for fix timer with two resend buttons
	private var timerHasBeenStarted = false

	private func startResendTimer(type: InputType) {
		switch type {
			case .email:
				if EmailAndCodeInputsViewController.resendEmailTimerDuration <= 0 {
					EmailAndCodeInputsViewController.resendEmailTimerDuration = input.resendEmailCodeTimer
				}
				repeatEmailButton.setTitle(
					NSLocalizedString("email_and_code_validation_resend_availability", comment: "") +
					(timeFormatter.string(from: EmailAndCodeInputsViewController.resendEmailTimerDuration) ?? ""),
					for: .normal
				)
			case .sms:
				if EmailAndCodeInputsViewController.resendSmsTimerDuration <= 0 {
					EmailAndCodeInputsViewController.resendSmsTimerDuration = input.resendSmsCodeTimer
				}
				repeatSmsButton.setTitle(
					NSLocalizedString("email_and_code_validation_resend_availability", comment: "") +
					(timeFormatter.string(from: EmailAndCodeInputsViewController.resendSmsTimerDuration) ?? ""),
					for: .normal
				)
		}
		
		if !timerHasBeenStarted {
			timerHasBeenStarted = true
			Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(resendTimerTick(_:)), userInfo: nil, repeats: true)
		}
	}

	@objc func resendTimerTick(_ timer: Timer) {
		let tappedButtonType = repeatSmsButton.isEnabled ? InputType.email : InputType.sms
		var smsTimerDuration = 0.0
		var emailTimerDuration = 0.0
		EmailAndCodeInputsViewController.resendEmailTimerDuration -= 1.0
		EmailAndCodeInputsViewController.resendSmsTimerDuration -= 1.0
		
		if !repeatEmailButton.isEnabled && !repeatSmsButton.isEnabled {
			emailTimerDuration = EmailAndCodeInputsViewController.resendEmailTimerDuration
			smsTimerDuration = EmailAndCodeInputsViewController.resendSmsTimerDuration
		} else {
			switch tappedButtonType {
				case .email:
					emailTimerDuration = EmailAndCodeInputsViewController.resendEmailTimerDuration
				case .sms:
					smsTimerDuration = EmailAndCodeInputsViewController.resendSmsTimerDuration
			}

			timer.invalidate()
			timerHasBeenStarted = false
		}
		
		
		if tappedButtonType == .email && emailTimerDuration <= 0.0
			|| tappedButtonType == .sms && smsTimerDuration <= 0.0 {
			switch tappedButtonType {
				case .email:
					repeatEmailButton.isEnabled = true
					repeatEmailButton.setTitle(NSLocalizedString("email_and_code_validation_resend_again", comment: ""), for: .normal)
				case .sms:
					repeatSmsButton.isEnabled = true
					repeatSmsButton.setTitle(NSLocalizedString("email_and_code_validation_resend_again", comment: ""), for: .normal)
			}
		} else {
			if !repeatEmailButton.isEnabled && !repeatSmsButton.isEnabled {
				repeatEmailButton.setTitle(
					NSLocalizedString("email_and_code_validation_resend_availability", comment: "") +
					(timeFormatter.string(from: EmailAndCodeInputsViewController.resendEmailTimerDuration) ?? ""),
					for: .normal
				)
				repeatSmsButton.setTitle(
					NSLocalizedString("email_and_code_validation_resend_availability", comment: "") +
					(timeFormatter.string(from: EmailAndCodeInputsViewController.resendSmsTimerDuration) ?? ""),
					for: .normal
				)
				
				return
			}

			switch tappedButtonType {
				case .email:
					repeatEmailButton.isEnabled = false
					repeatEmailButton.setTitle(
						NSLocalizedString("email_and_code_validation_resend_availability", comment: "") +
						(timeFormatter.string(from: EmailAndCodeInputsViewController.resendEmailTimerDuration) ?? ""),
						for: .normal
					)
				case .sms:
					repeatSmsButton.isEnabled = false
					
					repeatSmsButton.setTitle(
						NSLocalizedString("email_and_code_validation_resend_availability", comment: "") +
						(timeFormatter.string(from: EmailAndCodeInputsViewController.resendSmsTimerDuration) ?? ""),
						for: .normal
					)
			}
		}
	}

	@objc func emailInputEventsBegin() {
		moveUpButton()
		chatTransitionTextView.isHidden = true
		scrollView.scrollVertical(offset: smsCodeInput.bounds.width + 160, animated: true)
		hideErrors()
	}
	
	@objc func smsInputEventsBegin() {
		moveUpButton()
		chatTransitionTextView.isHidden = true
		hideErrors()
	}
	
	@objc func inputEventsEnd() {
		moveDownButton()
		chatTransitionTextView.isHidden = false
		updateEnterButton()
	}
	
	@objc func allInputEvents() {
		updateEnterButton()
	}
	
	private func updateEnterButton() {
		continueButton.isEnabled = smsCodeInput.isValid && emailCodeInput.isValid
	}
	
	private func hideErrors() {
		smsCodeInput.error(show: false)
		emailCodeInput.error(show: false)
	}
	
	private func moveUpButton() {
		buttonTopConstraint.isActive = true
		buttonBottomConstraint.isActive = false
	}
	
	private func moveDownButton() {
		buttonTopConstraint.isActive = false
		buttonBottomConstraint.isActive = true
	}
	
	func showError(errorMessage: String?) {
		errorInfoTitleLabel.text = errorMessage
		errorBackgroundView.isHidden = false
		smsCodeInput.error(show: true)
		emailCodeInput.error(show: true)
		moveDownButton()
	}
	
	@objc private func hideKeyboard() {
		emailCodeInput.resignFirstResponder()
		smsCodeInput.resignFirstResponder()
		view.endEditing(true)
	}
	
	private func setupContinueButton() {
		view.addSubview(continueButton)
		
		continueButton <~ Style.RoundedButton.primaryButtonSmall
		
		continueButton.setTitle(
			NSLocalizedString("common_continue", comment: ""),
			for: .normal
		)
		continueButton.addTarget(self, action: #selector(continueButtonTap), for: .touchUpInside)
		continueButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			continueButton.heightAnchor.constraint(equalToConstant: 48),
		])
		
		continueButton.isEnabled = false
		
		buttonBottomConstraint = continueButton.bottomToSuperview(offset: -9, usingSafeArea: true)
		continueButton.horizontalToSuperview(insets: .horizontal(Constants.horizontalInsets))
	}
	
	@objc func continueButtonTap() {
		if continueButton.isEnabled {
			timerHasBeenStarted = false
			hideKeyboard()
			output.validationPassed(emailCodeInput.textField.text ?? "", smsCodeInput.textField.text ?? "")
		}
	}
	
	struct Constants {
		static let horizontalInsets: CGFloat = 18
		static let maxCodeLenght: Int = 4
	}
	
	// MARK: - UITextField Delegate
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let currentString = (textField.text ?? "") as NSString
		let newString =  currentString.replacingCharacters(in: range, with: string) as NSString

		return newString.length <= Constants.maxCodeLenght
	}
}

extension String {
	func maskedEmailString(maxNameLength: Int, maxDomainLength: Int) -> String {
		var emailAdress = self
		if let separatorIndex = emailAdress.range(of: "@")?.lowerBound {
			let emailNameEndIndex = emailAdress.index(separatorIndex, offsetBy: -1)
			let emailNameLenght = emailAdress.distance(from: emailAdress.startIndex, to: emailNameEndIndex)
			
			if emailNameLenght >= maxNameLength {
				emailAdress.replaceSubrange(emailAdress.index(emailAdress.startIndex, offsetBy: 2)...emailNameEndIndex, with: "***")
			} else if emailNameLenght >= 2 {
				emailAdress.replaceSubrange(emailAdress.index(emailAdress.startIndex, offsetBy: 1)...emailNameEndIndex, with: "***")
			} else if emailNameLenght == 1 {
				emailAdress.replaceSubrange(...emailNameEndIndex, with: "***")
			}

		}
		
		if let separatorIndex = emailAdress.range(of: "@")?.lowerBound {
			let emailDomainLenght = emailAdress.distance(from: separatorIndex, to: emailAdress.endIndex)
			
			if emailDomainLenght > maxDomainLength {
				emailAdress.replaceSubrange(
					emailAdress.index(separatorIndex, offsetBy: 1)...,
					with: "***" + emailAdress.suffix(6)
				)
			}
		}
		
		return emailAdress
	}
}

extension UIScrollView {
	// Scroll to a specific view so that it's top is at the top our scrollview
	func scrollVertical(offset: CGFloat, animated: Bool) {
		// Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
		self.scrollRectToVisible(CGRect(x: 0, y: offset, width: 1, height: 1), animated: animated)
	}
}
