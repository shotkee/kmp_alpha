//
//  SignInSMSCodeViewController.swift
//  AlfaStrah
//
//  Created by Makson on 17.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints

class SignInSMSCodeViewController: ViewController
{
	var input: Input!
	
	struct Input {
		let phoneDisplayString: String
		let isMaskedPhoneNumber: Bool
		var resendSmsCodeTimer: TimeInterval
	}
	
	struct Notify {
		let showError: (_ message: String?) -> Void
		let updateSmsCodeTimer: (_ time: TimeInterval) -> Void
	}
	
	private(set) lazy var notify = Notify(
		showError: { [weak self] message in
			
			self?.errorLabel.text = message
			self?.setVisibleErrorLabel(isHidden: message == nil)
			self?.wrongCode()
		},
		updateSmsCodeTimer: { [weak self] timer in
			
			self?.input.resendSmsCodeTimer = timer
			self?.startResendTimer()
		}
	)
	
	var output: Output!
	
	struct Output {
		let goBack: () -> Void
		let toChat: () -> Void
		let verify: (String) -> Void
		let resendSms: () -> Void
	}
	
	// MARK: - Variables
	private let repeatButton = RoundEdgeButton()
	private let actionContainerView = UIView()
	private let phoneLabel = UILabel()
	private let chatTransitionTextView = LinkedTextView()
	private let errorLabel = UILabel()
	
	private let timeFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [ .minute, .second ]
		formatter.zeroFormattingBehavior = [ .pad ]
		return formatter
	}()
	
	private lazy var bottomConstraint: NSLayoutConstraint = {
		return chatTransitionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.distanceToKeyboard)
	}()
	
	static var resendTimerDuration: TimeInterval = 0.0
	
	private let codeInputView = DigitsCodeInputView(frame: .zero, length: 6)
	
	@objc func resendSmsCode(_ sender: Any) {
		codeInputView.clear()
		setVisibleErrorLabel(isHidden: true)
		output.resendSms()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = NSLocalizedString("sign_in_sms_code_screen_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
		setupUI()
		addRightButton(title: NSLocalizedString("auth_sign_up_chat_nav_item_title", comment: ""), action: output.toChat)
    }
	
	private func setupUI()
	{
		subscribeForKeyboardNotifications()
		
		setupPhoneLabel()
		setupCodeInputView()
		setupActionContainerView()
		setupRepeatButton()
		setupErrorLabel()
		
		startResendTimer()
		
		setupChatTransitionTextView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		codeInputView.becomeActive()
	}
		
	private func setupPhoneLabel() {
		phoneLabel.textAlignment = .center
		phoneLabel.numberOfLines = 0
		
		let maskedPhoneNumber = input.isMaskedPhoneNumber ? input.phoneDisplayString : input.phoneDisplayString.maskedPhoneString(2)
	   
		let attributedMaskedPhoneNumber = NSMutableAttributedString(
			string: maskedPhoneNumber,
			attributes: [
				.foregroundColor: UIColor.Text.textAccent
			]
		)
		
		let title = ((NSLocalizedString("sign_in_sms_code_screen_sms_send", comment: "") + " ") <~ Style.TextAttributes.primaryHeadline2).mutable
		title.append(attributedMaskedPhoneNumber)
		phoneLabel.attributedText = title

		phoneLabel.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(phoneLabel)
		
		NSLayoutConstraint.activate([
			phoneLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: getTopAnchorPhoneLabel()),
			phoneLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
			phoneLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
		])
	}
	
	private func getTopAnchorPhoneLabel() -> CGFloat {
		switch UIScreen.main.bounds.height {
			case 568.0:
				return 12
			case 667.0:
				return 76
			default:
				return 126
		}
	}
	
	private func startResendTimer() {
		if SignInSMSCodeViewController.resendTimerDuration <= 0 {
			SignInSMSCodeViewController.resendTimerDuration = input.resendSmsCodeTimer
		}
		
		repeatButton.setTitle(
			NSLocalizedString("auth_phone_sms_code_resend_availability", comment: "") +
			(timeFormatter.string(from: SignInSMSCodeViewController.resendTimerDuration) ?? ""),
			for: .normal
		)
		repeatButton.isEnabled = false
		Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(resendTimerTick(_:)), userInfo: nil, repeats: true)
	}

	private func setupCodeInputView() {
		codeInputView.output = .init(
			codeEntered: { [weak self] code in
				self?.output.verify(code)
			},
			onEditingChanged: { [weak self] in
				self?.setVisibleErrorLabel(isHidden: true)
			}
		)
		
		view.addSubview(codeInputView)
		
		codeInputView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			codeInputView.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 36),
			codeInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
			codeInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
			codeInputView.heightAnchor.constraint(equalToConstant: 50)
		])
	}
	
	private func setupActionContainerView() {
		actionContainerView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(actionContainerView)
		
		NSLayoutConstraint.activate([
			actionContainerView.topAnchor.constraint(equalTo: codeInputView.bottomAnchor, constant: 28),
			actionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
			actionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
			actionContainerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
		])
	}
	
	private func setupRepeatButton() {
		repeatButton <~ Style.RoundedButton.accentButtonSmall
		repeatButton.translatesAutoresizingMaskIntoConstraints = false
		repeatButton.setTitle(NSLocalizedString("auth_phone_sms_code_resend_again", comment: ""), for: .normal)
		repeatButton.addTarget(self, action: #selector(resendSmsCode(_:)), for: .touchUpInside)
	   
		actionContainerView.addSubview(repeatButton)
		
		NSLayoutConstraint.activate([
			repeatButton.centerXAnchor.constraint(equalTo: actionContainerView.centerXAnchor),
			repeatButton.topAnchor.constraint(equalTo: actionContainerView.topAnchor),
			repeatButton.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor),
			repeatButton.heightAnchor.constraint(equalToConstant: 36)
		])
	}
	
	private func setVisibleErrorLabel(isHidden: Bool){
		errorLabel.isHidden = isHidden
	}
	
	private func setupErrorLabel() {
		view.addSubview(errorLabel)
		errorLabel <~ Style.Label.accentText
		errorLabel.text = ""
		errorLabel.isHidden = true
		errorLabel.numberOfLines = 0
		errorLabel.textAlignment = .center
		errorLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
			errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
			errorLabel.topAnchor.constraint(equalTo: actionContainerView.bottomAnchor, constant: 15),
			errorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18)
		])
		
	}
	
	private func setupChatTransitionTextView() {
		chatTransitionTextView.backgroundColor = .clear
		chatTransitionTextView.translatesAutoresizingMaskIntoConstraints = false
		chatTransitionTextView.textContainerInset = .zero
		
		let link = LinkArea(
			text: NSLocalizedString("auth_phone_sms_code_chat_link_text", comment: ""),
			link: nil,
			tapHandler: { [weak self] _ in
				self?.output.toChat()
			}
		)

		chatTransitionTextView.set(
			text: NSLocalizedString("auth_phone_sms_code_chat", comment: ""),
			userInteractionWithTextEnabled: true,
			links: [ link ],
			textAttributes: Style.TextAttributes.secondaryText,
			linkColor: .Text.textPrimary,
			isUnderlined: false
		)

		chatTransitionTextView.textAlignment = .center

		view.addSubview(chatTransitionTextView)

		NSLayoutConstraint.activate([
			chatTransitionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
			chatTransitionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
			chatTransitionTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			chatTransitionTextView.heightAnchor.constraint(equalToConstant: 18),
			bottomConstraint
		])
	}

	func wrongCode() {
		codeInputView.error()
	}
	
	@objc func resendTimerTick(_ timer: Timer) {
		SignInSMSCodeViewController.resendTimerDuration -= 1.0
		if SignInSMSCodeViewController.resendTimerDuration <= 0.0 {
			repeatButton.isEnabled = true
			
			repeatButton.setTitle(NSLocalizedString("auth_phone_sms_code_resend_again", comment: ""), for: .normal)

			timer.invalidate()
		} else {
			repeatButton.isEnabled = false
						
			repeatButton.setTitle(
				NSLocalizedString("auth_phone_sms_code_resend_availability", comment: "") +
				(timeFormatter.string(from: SignInSMSCodeViewController.resendTimerDuration) ?? ""),
				for: .normal
			)
		}
	}
	
	// MARK: - Keyboard notifications handling
	private func subscribeForKeyboardNotifications() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillChange),
			name: UIResponder.keyboardWillChangeFrameNotification,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}
											   
	@objc func keyboardWillChange(_ notification: NSNotification) {
		moveViewWithKeyboard(notification: notification)
	}
	
	@objc func keyboardWillHide(_ notification: NSNotification) {
		bottomConstraint.constant = -20
	}
		
	func moveViewWithKeyboard(notification: NSNotification) {
		guard let userInfo = notification.userInfo,
			  let keyboardHeight = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue)?.height
		else { return }

		let constraintConstant = -(keyboardHeight + Constants.distanceToKeyboard)
		
		if bottomConstraint.constant != constraintConstant {
			bottomConstraint.constant = constraintConstant
		}
	}
	
	struct Constants {
		static let distanceToKeyboard: CGFloat = is7IphoneOrLess ? 12 : -12
		static let is7IphoneOrLess: Bool = UIScreen.main.bounds.height <= 667.0
	}
}
