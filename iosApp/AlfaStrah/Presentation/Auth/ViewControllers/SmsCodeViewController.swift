//
//  SmsCodeViewController.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 18/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import Foundation
import IQKeyboardManagerSwift

class SmsCodeViewController: ViewController {
    struct Notify {
        var resetOtpCode: () -> Void
        var otpVerificationFailed: (String) -> Void
        var bringFocusToOtp: () -> Void
    }

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        resetOtpCode: { [weak self] in
            self?.codeInputView.clear()
        },
        otpVerificationFailed: { [weak self] message in
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            self?.codeInputView.error()
            self?.errorLabel.text = message
            self?.setVisibleErrorLabel(isHidden: message.isEmpty)
        },
        bringFocusToOtp: { [weak self] in
            self?.codeInputView.setFocus()
        }
    )
    
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
    
	private let codeInputView = DigitsCodeInputView(frame: .zero, length: 4)

    struct Output {
        var verify: (String) -> Void
        var resendSms: () -> Void
        var openChat: () -> Void
    }

    struct Input {
        let phoneDisplayString: String
        let isMaskedPhoneNumber: Bool
        let resendSmsCodeTimer: TimeInterval
    }

    var input: Input!
    var output: Output!

    @objc func resendSmsCode(_ sender: Any) {
        codeInputView.clear()
        setVisibleErrorLabel(isHidden: true)
        output.resendSms()
        startResendTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        title = NSLocalizedString("auth_phone_sms_code_title", comment: "")
        
		view.backgroundColor = .Background.backgroundContent
        
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
        
        let title = ((NSLocalizedString("auth_phone_sms_sent", comment: "") + " ") <~ Style.TextAttributes.primaryHeadline2).mutable
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
        if SmsCodeViewController.resendTimerDuration <= 0 {
            SmsCodeViewController.resendTimerDuration = input.resendSmsCodeTimer
        }
        
        repeatButton.setTitle(
            NSLocalizedString("auth_phone_sms_code_resend_availability", comment: "") +
            (timeFormatter.string(from: SmsCodeViewController.resendTimerDuration) ?? ""),
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
            codeInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            codeInputView.widthAnchor.constraint(equalToConstant: 207),
            codeInputView.heightAnchor.constraint(equalToConstant: 60)
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
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: actionContainerView.bottomAnchor, constant: 15),
            errorLabel.heightAnchor.constraint(equalToConstant: 18)
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
                self?.output.openChat()
            }
        )

        chatTransitionTextView.set(
            text: NSLocalizedString("auth_phone_sms_code_chat", comment: ""),
            userInteractionWithTextEnabled: true,
            links: [ link ],
			textAttributes: Style.TextAttributes.secondaryText,
			linkColor: .Text.textPrimary
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
        SmsCodeViewController.resendTimerDuration -= 1.0
        if SmsCodeViewController.resendTimerDuration <= 0.0 {
            repeatButton.isEnabled = true
            
            repeatButton.setTitle(NSLocalizedString("auth_phone_sms_code_resend_again", comment: ""), for: .normal)

            timer.invalidate()
        } else {
            repeatButton.isEnabled = false
                        
            repeatButton.setTitle(
                NSLocalizedString("auth_phone_sms_code_resend_availability", comment: "") +
                (timeFormatter.string(from: SmsCodeViewController.resendTimerDuration) ?? ""),
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
    }
                                               
    @objc func keyboardWillChange(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification)
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
