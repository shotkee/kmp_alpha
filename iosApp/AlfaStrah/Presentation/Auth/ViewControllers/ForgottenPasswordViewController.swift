//
//  ForgottenPasswordViewController.swift
//  AlfaStrah
//
//  Created by vit on 21.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import IQKeyboardManagerSwift

class ForgottenPasswordViewController: ViewController {
    enum State {
        case loading
        case failure
        case data
    }
    
    struct Notify {
        let showError: (_ message: String) -> Void
        let update: (_ state: State) -> Void
    }

    private(set) lazy var notify = Notify(
        showError: { [weak self] message in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            self.showError(with: message)
        },
        update: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(with: state)
        }
    )
    
    struct Output {
        let resetPassword: (_ phone: String, _ email: String) -> Void
        let toChat: () -> Void
        let close: () -> Void
    }

    var output: Output!
    
    private let scrollView = UIScrollView()
    private let previousNextView = IQPreviousNextView()
    private let contentStackView = UIStackView()
    private let actionButtonsStackView = UIStackView()
    private let continueButton = RoundEdgeButton()
    private let descriptionLabel = UILabel()
    private let phoneInput = CommonTextInput()
    private let emailInput = CommonTextInput()
    private let errorLabelContainer = UIStackView()
    private let continueErrorLabel = UILabel()
    
    private let operationStatusView: OperationStatusView = .init(frame: .zero)
    
    private lazy var textFieldController: TextFieldController = TextFieldController(
        textField: phoneInput.textField,
        asYouTypeFormatter: PhoneNumberFormatter(predefinedAreaCode: 7, maxNumberLength: 10)
    )
    
    private lazy var bottomButtonsConstraint: NSLayoutConstraint = {
        return actionButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		title = NSLocalizedString("forgotten_password_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
        
        setupScrollView()
        setupContentStackView()
        setupActionButtonStackView()
        setupContinueButton()
        
        setupDescriptionLabel()
        setupTextInputs()
        setupContinueErrorLabel()
        
        subscribeForKeyboardNotifications()
        
        setupOperationStatusView()
        updateContinueButton()
        
        addRightButton(title: NSLocalizedString("auth_sign_up_chat_nav_item_title", comment: ""), action: output.toChat)
    }
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: view))
        operationStatusView.isHidden = true
    }

    
    // MARK: - ViewController state
    private func update(with state: State) {
        switch state {
            case .loading:
                self.navigationItem.rightBarButtonItem = nil
                
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("auth_sign_in_loading_description", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
            case .failure:
                self.navigationItem.rightBarButtonItem = nil
                
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("auth_sign_in_error_title", comment: ""),
                    description: NSLocalizedString("auth_sign_in_error_description", comment: ""),
                    icon: UIImage(named: "icon-common-failure")
                ))
                
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("common_go_to_chat", comment: ""),
                        isPrimary: false,
                        action: {
                            self.output.toChat()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("common_retry", comment: ""),
                        isPrimary: true,
                        action: { [weak self] in
                            guard let self = self
                            else { return }
                            
                            let phone = self.textFieldController.unformattedString
                            let email = self.emailInput.textField.text ?? ""
                            
                            self.output.resetPassword(self.stripSymbols(phone), email)
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
                operationStatusView.isHidden = false
            case .data:
                operationStatusView.isHidden = true
                scrollView.isHidden = false
				addRightButton(title: NSLocalizedString("auth_sign_up_chat_nav_item_title", comment: ""), action: output.toChat)

        }
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)

        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: scrollView, in: view))
    }

    private func setupContentStackView() {
        scrollView.addSubview(previousNextView)

        previousNextView.addSubview(contentStackView)
        previousNextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previousNextView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            previousNextView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            previousNextView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            previousNextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            previousNextView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 9, left: 18, bottom: 0, right: 18)
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 0
        contentStackView.backgroundColor = .clear
        contentStackView.clipsToBounds = false

        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: contentStackView, in: previousNextView))
    }
    
    private func setupActionButtonStackView() {
        view.addSubview(actionButtonsStackView)

        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 9, left: 18, bottom: 18, right: 18)
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .fill
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.spacing = 0
        actionButtonsStackView.backgroundColor = .clear

        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButtonsConstraint
        ])
    }

    private func setupContinueButton() {
        continueButton <~ Style.RoundedButton.primaryButtonLarge
        
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
        
        actionButtonsStackView.addArrangedSubview(continueButton)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = NSLocalizedString("forgotten_password_description", comment: "")
        contentStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupTextInputs() {
        contentStackView.addArrangedSubview(spacer(21))
        
        phoneInput.isValid = false
        phoneInput.textField.placeholder = NSLocalizedString("auth_sign_up_phone", comment: "")
        phoneInput.showErrorState = false
        phoneInput.textField.keyboardType = .phonePad
        phoneInput.textField.addTarget(self, action: #selector(phoneInputAllEditingEvents), for: .allEditingEvents)
        phoneInput.textField.addTarget(self, action: #selector(phoneInputDidEnd), for: .editingDidEnd)
        contentStackView.addArrangedSubview(phoneInput)
        phoneInput.validationRules = [
            LengthValidationRule(countChars: 18)
        ]
        
        contentStackView.addArrangedSubview(spacer(12))
        
        emailInput.isValid = false
        emailInput.textField.autocapitalizationType = .none
        emailInput.textField.placeholder = NSLocalizedString("auth_sign_up_email", comment: "")
        emailInput.textField.keyboardType = .emailAddress
        emailInput.shouldShowValidateStateAsYouType = false
        emailInput.textField.addTarget(self, action: #selector(emailInputEvents), for: .editingChanged)
        emailInput.textField.addTarget(self, action: #selector(emailInputDidEnd), for: .editingDidEnd)
        contentStackView.addArrangedSubview(emailInput)
        emailInput.validationRules = [
            EmailByDataDetectorValidationRule()
        ]
    }
    
    @objc func phoneInputAllEditingEvents() {
        hideErrors()
        _ = textFieldController.formattedString(from: textFieldController.unformattedString)
        updateContinueButton()
    }
    
    @objc func phoneInputDidEnd() {
        updateContinueButton()
    }
        
    @objc func emailInputEvents() {
        hideErrors()
        updateContinueButton()
    }
    
    @objc func emailInputDidEnd() {
        updateContinueButton()
    }
    
    private func updateContinueButton() {
        continueButton.isEnabled = emailInput.isValid && phoneInput.isValid
    }
    
    private func setupContinueErrorLabel() {
        errorLabelContainer.alignment = .fill
        errorLabelContainer.distribution = .fill
        errorLabelContainer.axis = .vertical
        errorLabelContainer.spacing = 0
        errorLabelContainer.backgroundColor = .clear
        
        continueErrorLabel <~ Style.Label.negativeSubhead
        continueErrorLabel.numberOfLines = 0
        
        contentStackView.addArrangedSubview(spacer(12))
        errorLabelContainer.addArrangedSubview(continueErrorLabel)
        
        contentStackView.addArrangedSubview(errorLabelContainer)
        
        errorLabelContainer.isHidden = true

        contentStackView.addArrangedSubview(spacer(15))
    }
    
    
    @objc func continueButtonTap() {
        let phone = textFieldController.unformattedString
        let email = emailInput.textField.text ?? ""
        
        output.resetPassword(stripSymbols(phone), email)
        
        hideKeyboard()
    }

    private func stripSymbols(_ phone: String) -> String {
        phone
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }
    
    private func showError(with message: String) {
        continueErrorLabel.text = message
        errorLabelContainer.isHidden = false
    }
    
    private func hideErrors() {
        continueErrorLabel.text = ""
        errorLabelContainer.isHidden = true
    }
    
    private func hideKeyboard() {
        view.endEditing(true)
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
        bottomButtonsConstraint.constant = 0
    }
    
    func moveViewWithKeyboard(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
        else { return }
        
        let constraintConstant = -keyboardHeight
        
        if  bottomButtonsConstraint.constant != constraintConstant {
            bottomButtonsConstraint.constant = constraintConstant
        }
    }
}
