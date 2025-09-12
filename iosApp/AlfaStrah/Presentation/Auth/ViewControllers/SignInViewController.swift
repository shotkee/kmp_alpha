//
//  SignInViewController.swift
//  AlfaStrah
//
//  Created by vit on 21.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import IQKeyboardManagerSwift
import TinyConstraints

class SignInViewController: ViewController {
    enum State {
        case loading
        case failure
        case data
    }
	
	enum AuthType
	{
		case phone(String)
		case emailAndPassword(String, String)
	}
	
	enum SelectedTab: Int
	{
		case phone = 0
		case emailAndPassword = 1
	}
	
	private var selectedTab: SelectedTab = .phone {
		didSet {
			updateState()
		}
	}
    
    struct Notify {
        let showError: (_ message: String) -> Void
        let update: (_ state: State) -> Void
		let updateColorBorderTextFieldAndState: (_ isError: Bool, _ state: State) -> Void
		let updateSelectedTabSwitch: (_ index: Int) -> Void
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
        },
		updateColorBorderTextFieldAndState: { [weak self] isError, state in
			guard let self = self
			else { return }
			
			self.update(with: state)
			self.phoneInput.error(show: isError)
		},
		updateSelectedTabSwitch: { [weak self] index in
			guard let self = self,
				  self.isViewLoaded
			else { return }
			
			self.switchView.updateSelectedIndex(index: index)
		}
    )
    
    struct Output {
        let goBack: () -> Void
        let forgotPassword: () -> Void
		let signIn: (_ authType: AuthType) -> Void
        let toChat: () -> Void
        let openLink: (_ url: URL) -> Void
        let showAllRegistrationMethods: () -> Void
        let close: () -> Void
    }

    var output: Output!
    
    private let scrollView = UIScrollView()
    private let previousNextView = IQPreviousNextView()
    private let contentStackView = UIStackView()
    private let actionButtonsStackView = UIStackView()
    private let enterButton = RoundEdgeButton()
	private let switchView = RMRStyledSwitch()
	private let textInputsStackview = UIStackView()
    private let descriptionLinkedText = LinkedTextView()
    private let loginInput = CommonTextInput()
    private let passwordInput = CommonTextInput()
	private let phoneInput = CommonTextInput()
    private let errorLabelContainer = UIStackView()
    private let enterErrorLabel = UILabel()
	private let errorSpacer = spacer(21)
    private let forgotPasswordButton = UIButton(type: .system)
    private let allRegistrationMethodsButton = RoundEdgeButton()
    
    private let operationStatusView: OperationStatusView = .init(frame: .zero)
    
    private lazy var bottomButtonsConstraint: NSLayoutConstraint = {
        return actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    }()
	
	private lazy var textFieldController: TextFieldController = TextFieldController(
		textField: phoneInput.textField,
		asYouTypeFormatter: PhoneNumberFormatter(predefinedAreaCode: 7, maxNumberLength: 10)
	)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		title = NSLocalizedString("auth_sign_in_title", comment: "")
		
        view.backgroundColor = .Background.backgroundContent
        
        setupScrollView()
        setupContentStackView()
        setupActionButtonStackView()
        setupAllRegistrationMethodsButton()
        setupContinueButton()
		setupPhoneTextInput()
        
        setupDescriptionLinkedTextView()
		setupSwitchView()
		setupTextInputsStackView()
		updateState()
        subscribeForKeyboardNotifications()
        setupOperationStatusView()
        
		addRightButton(title: NSLocalizedString("auth_sign_up_chat_nav_item_title", comment: ""), action: output.toChat)
    }
	
	private func setupEmailAndPasswordContentTextInputsStackView() {
		setupTextInputs()
		setupContinueErrorLabel()
		setupForgotPasswordButton()
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
                            
							self.signIn()
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
                operationStatusView.isHidden = false
            case .data:
                errorLabelContainer.isHidden = true
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
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
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
        actionButtonsStackView.spacing = 9
        actionButtonsStackView.backgroundColor = .clear

        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButtonsConstraint
        ])
    }

    private func setupContinueButton() {
        enterButton <~ Style.RoundedButton.primaryButtonLarge
        
        enterButton.setTitle(
            NSLocalizedString("auth_sign_in_sign_in", comment: ""),
            for: .normal
        )
        
        enterButton.addTarget(self, action: #selector(enterButtonTap), for: .touchUpInside)
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            enterButton.heightAnchor.constraint(equalToConstant: 48),
        ])
        
        actionButtonsStackView.addArrangedSubview(enterButton)
        
        enterButton.isEnabled = false
    }
    
    private func setupDescriptionLinkedTextView() {
        descriptionLinkedText.translatesAutoresizingMaskIntoConstraints = false
        descriptionLinkedText.textContainerInset = .zero
        
        let linkPath = NSLocalizedString("auth_sign_in_description_link", comment: "")
        
        let link = LinkArea(
            text: linkPath,
            link: URL(string: "https://" + linkPath),
            tapHandler: { [weak self] url in
                guard let url = url
                else { return }
                
                self?.output.openLink(url)
            }
        )
		
		descriptionLinkedText.set(
			text: NSLocalizedString("auth_sign_in_description", comment: ""),
			userInteractionWithTextEnabled: true,
			links: [ link ],
			textAttributes: [
				.foregroundColor: UIColor.Text.textSecondary,
				.font: Style.Font.text
			],
			linkColor: .Text.textLink,
			isUnderlined: false
		)
        
        contentStackView.addArrangedSubview(descriptionLinkedText)
    }
	
	private func setupSwitchView()
	{
		contentStackView.addArrangedSubview(spacer(20))
		switchView.style(
			leftTitle: NSLocalizedString("auth_sign_switch_left_title", comment: ""),
			rightTitle: NSLocalizedString("auth_sign_switch_right_title", comment: ""),
			titleColor: .Text.textPrimary,
			backgroundColor: .Background.backgroundTertiary,
			selectedTitleColor: .Text.textContrast,
			selectedBackgroundColor: .Background.segmentedControlAccent
		)
		switchView.height(42)
		switchView.clipsToBounds = true
		switchView.layer.cornerRadius = 21
		switchView.addTarget(
			self,
			action: #selector(switchTap),
			for: .valueChanged
		)
		
		contentStackView.addArrangedSubview(switchView)
	}
	
	@objc private func switchTap() {
		guard let newSelectedTab = SelectedTab(rawValue: switchView.selectedIndex)
		else { return }

		selectedTab = newSelectedTab
	}
	
	private func updateState()
	{
		textInputsStackview.subviews.forEach { $0.removeFromSuperview() }
		
		switch selectedTab
		{
			case .phone:
				textInputsStackview.addArrangedSubview(phoneInput)
				setupContinueErrorLabel()
			
			case .emailAndPassword:
				setupEmailAndPasswordContentTextInputsStackView()
		}
		
		updateEnterButton()
	}
	
	private func setupTextInputsStackView() {
		contentStackView.addArrangedSubview(spacer(20))
		textInputsStackview.axis = .vertical
		contentStackView.addArrangedSubview(textInputsStackview)
	}
	
	private func setupPhoneTextInput()
	{
		phoneInput.textField.placeholder = NSLocalizedString("auth_sign_phone", comment: "")
		phoneInput.showErrorState = false
		phoneInput.textField.keyboardType = .phonePad
		phoneInput.textField.addTarget(self, action: #selector(phoneInputAllEditingEvents), for: .allEditingEvents)
		phoneInput.isValid = false
		phoneInput.validationRules = [
			LengthValidationRule(countChars: 18),
			RequiredValidationRule()
		]
		phoneInput.height(56)
	}
	
	@objc func phoneInputAllEditingEvents() {
		hideErrors()
		_ = textFieldController.formattedString(from: textFieldController.unformattedString)
		updateEnterButton()
	}
    
    private func setupTextInputs() {
        loginInput.textField.placeholder = NSLocalizedString("auth_sign_in_user_login", comment: "")
        loginInput.textField.keyboardType = .emailAddress
        loginInput.textField.autocapitalizationType = .none
        loginInput.textField.addTarget(self, action: #selector(inputEventsBegin), for: .editingDidBegin)
        loginInput.textField.addTarget(self, action: #selector(allInputEvents), for: .allEditingEvents)
        loginInput.isValid = false
        loginInput.validateAsYouType = false
        loginInput.validationRules = [
            EmailByDataDetectorValidationRule()
        ]
		loginInput.height(56)
		textInputsStackview.addArrangedSubview(loginInput)
        
		textInputsStackview.addArrangedSubview(spacer(9))
        
        passwordInput.isValid = false
        passwordInput.textField.placeholder = NSLocalizedString("auth_sign_in_user_password", comment: "")
		passwordInput.textField.rightViewKind = .securityButton
        passwordInput.textField.isSecureTextEntry = true
        passwordInput.textField.addTarget(self, action: #selector(inputEventsBegin), for: .editingDidBegin)
        passwordInput.textField.addTarget(self, action: #selector(allInputEvents), for: .allEditingEvents)
        passwordInput.validationRules = [
            RequiredValidationRule()
        ]
		passwordInput.height(56)
        
		textInputsStackview.addArrangedSubview(passwordInput)
    }
    
    @objc func inputEventsBegin() {
        hideErrors()
    }
    
    @objc func allInputEvents() {
        updateEnterButton()
    }
    
    private func setupContinueErrorLabel() {
        errorLabelContainer.alignment = .fill
        errorLabelContainer.distribution = .fill
        errorLabelContainer.axis = .vertical
        errorLabelContainer.spacing = 0
        errorLabelContainer.backgroundColor = .clear
        
        enterErrorLabel <~ Style.Label.negativeSubhead
        enterErrorLabel.numberOfLines = 0
        
		textInputsStackview.addArrangedSubview(spacer(12))
        errorLabelContainer.addArrangedSubview(enterErrorLabel)
        
		textInputsStackview.addArrangedSubview(errorLabelContainer)
		textInputsStackview.addArrangedSubview(errorSpacer)
        
        errorLabelContainer.isHidden = true
		errorSpacer.isHidden = true
    }
    
    @objc func enterButtonTap() {
        updateEnterButton()
		signIn()
		hideKeyboard()
    }
	
	private func signIn()
	{
		let login = loginInput.textField.text ?? ""
		let password = passwordInput.textField.text ?? ""
		
		switch selectedTab
		{
			case .phone:
				if phoneInput.isValid {
					output.signIn(
						.phone(textFieldController.unformattedString)
					)
				}
			case .emailAndPassword:
				if loginInput.isValid && passwordInput.isValid {
					output.signIn(
						.emailAndPassword(login, password)
					)
				}
		}
	}
    
    private func showError(with message: String) {
        enterErrorLabel.text = message
        errorLabelContainer.isHidden = false
		errorSpacer.isHidden = false
    }
    
    private func hideErrors() {
        enterErrorLabel.text = ""
        errorLabelContainer.isHidden = true
		errorSpacer.isHidden = true
    }
    
    private func setupForgotPasswordButton() {
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.setTitle(
            NSLocalizedString("auth_sign_in_forgot_password", comment: ""),
            for: .normal
        )
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTap), for: .touchUpInside)
        forgotPasswordButton <~ Style.Button.accentLabelButtonSmall
        
        NSLayoutConstraint.activate([
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 36)
        ])
		textInputsStackview.addArrangedSubview(forgotPasswordButton)
    }
    
    private func setupAllRegistrationMethodsButton() {
        actionButtonsStackView.addArrangedSubview(spacer(21))
		allRegistrationMethodsButton.translatesAutoresizingMaskIntoConstraints = false
		allRegistrationMethodsButton.setTitle(
            NSLocalizedString("auth_sign_in_all_registration_methods_button_title", comment: ""),
            for: .normal
        )
		allRegistrationMethodsButton.addTarget(self, action: #selector(allRegistrationMethodsButtonTap), for: .touchUpInside)

		allRegistrationMethodsButton <~ Style.RoundedButton.primaryButtonLargeWithoutBorder
        
        NSLayoutConstraint.activate([
			allRegistrationMethodsButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        actionButtonsStackView.addArrangedSubview(allRegistrationMethodsButton)
    }
    
    // MARK: - Inputs validation handlers
    private func updateEnterButton()
	{
		switch selectedTab
		{
			case .phone:
				enterButton.setTitle(
					NSLocalizedString("auth_sign_in_get_code", comment: ""),
					for: .normal
				)
				enterButton.isEnabled = phoneInput.isValid
			
			case .emailAndPassword:
				enterButton.isEnabled = loginInput.isValid && passwordInput.isValid
				enterButton.setTitle(
					NSLocalizedString("auth_sign_in_sign_in", comment: ""),
					for: .normal
				)
		}
    }
    
    @objc func forgotPasswordButtonTap() {
        hideKeyboard()
        output.forgotPassword()
    }
    
    @objc func allRegistrationMethodsButtonTap() {
        hideKeyboard()
        output.showAllRegistrationMethods()
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
		allRegistrationMethodsButton.isHidden = true
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        bottomButtonsConstraint.constant = 0
		allRegistrationMethodsButton.isHidden = false
        updateEnterButton()
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
