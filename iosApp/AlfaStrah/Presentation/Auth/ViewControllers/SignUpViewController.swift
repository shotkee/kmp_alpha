//
//  SignUpViewController.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 10/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import IQKeyboardManagerSwift

class SignUpViewController: ViewController {
    enum State {
        case loading(title: String)
        case failure(title: String, description: String)
        case data(LinkedText?)
    }
    
    struct Notify {
        let update: (_ state: State) -> Void
        let showErrorInSection: (_ message: String) -> Void
    }

    private(set) lazy var notify = Notify(
        update: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            self.update(with: state)
        },
        showErrorInSection: { [weak self] message in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            self.update(with: .data(nil))
            
            self.showSignUpLabelError(with: message)
        }
    )
    
    struct RegistrationUserPersonalInfo {
        var lastname: String?
        var firstname: String?
        var patronymic: String?
        var hasPatronymic: Bool = true
        var phone: Phone?
        var birthDate: Date?
        var email: String?
        var insuranceId: String?
        var agreementConfirmed: Bool = false
        
        var isFilled: Bool {
            let values: [Any?] = [
                lastname,
                firstname,
                phone,
                birthDate,
                email
            ]
            return !values.contains { $0 == nil } &&
                (hasPatronymic ? patronymic != nil : true) &&
                agreementConfirmed
        }
    }
    
    private var registrationUserPersonalInfo = RegistrationUserPersonalInfo() {
        didSet {
            signUpButton.isEnabled = registrationUserPersonalInfo.isFilled
        }
    }
    
    private lazy var textFieldController: TextFieldController = TextFieldController(
        textField: phoneInput.textField,
        asYouTypeFormatter: PhoneNumberFormatter(predefinedAreaCode: 7, maxNumberLength: 10)
    )

    struct Input {
        let updateTerms: () -> Void
    }
    
    struct Output {
        let appear: () -> Void
        let signUp: (RegistrationUserPersonalInfo) -> Void
        let showDocument: (URL) -> Void
        let toChat: () -> Void
        let retry: () -> Void
        let close: () -> Void
    }

    var input: Input!
    var output: Output!
    
    private let scrollView = UIScrollView()
    private let previousNextView = IQPreviousNextView()
    private let contentStackView = UIStackView()
    private let actionButtonsStackView = UIStackView()
    private let insuranceNumberInput = CommonTextInput()
    private let lastnameInput = CommonTextInput()
    private let firstnameInput = CommonTextInput()
    private let phoneInput = CommonTextInput()
    private let birthDateInput = CommonTextInput()
    private let patronymicInput = CommonTextInput()
    private let emailInput = CommonTextInput()
    private let agreementView = CommonUserAgreementView()
    private let signUpButton = RoundEdgeButton()
    private let checkboxButton = CommonCheckboxButton()
    private let errorLabelContainer = UIView()
    private let signUpErrorLabel = UILabel()
    
    private let operationStatusView: OperationStatusView = .init(frame: .zero)
    
    private lazy var bottomContentStackViewConstraint: NSLayoutConstraint = {
        return contentStackView.bottomAnchor.constraint(
            equalTo: previousNextView.bottomAnchor,
            constant: -Contstatns.contentStackViewBottomOffset
        )
    }()
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
    @objc func signUpButtonTap() {
        analytics.track(event: AnalyticsEvent.Launch.registerProceed)
        
        errorLabelContainer.isHidden = true
        
        if registrationUserPersonalInfo.isFilled {
            output.signUp(registrationUserPersonalInfo)
        }
    }
    
    private func showSignUpLabelError(with message: String) {
        signUpErrorLabel.text = message
        errorLabelContainer.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        subscribeForKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        agreementView.resetConfirmation()
        
        signUpButton.isEnabled = registrationUserPersonalInfo.isFilled
        
        output.appear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height = stackViewBottomOffset()
        
        if bottomContentStackViewConstraint.constant != height {
            bottomContentStackViewConstraint.constant = height
        }
    }
    
    private func setupUI() {
        title = NSLocalizedString("auth_sign_up_register", comment: "")
        view.backgroundColor = .Background.backgroundContent
        
        setupScrollView()
        setupContentStackView()
        setupActionButtonStackView()
        setupSignUpButton()
        setupFields()
        setupSignUpErrorField()
        
        setupAgreementView()
        
        setupOperationStatusView()
    }
    
    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: view))
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
        NSLayoutConstraint.activate( NSLayoutConstraint.fill(view: previousNextView, in: scrollView) + [
            previousNextView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 21, left: 18, bottom: 0, right: 18)
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 9
        contentStackView.backgroundColor = .clear
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: previousNextView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: previousNextView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: previousNextView.trailingAnchor),
            bottomContentStackViewConstraint
        ])
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
            actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSignUpButton() {
        signUpButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        signUpButton.setTitle(
            NSLocalizedString("welcome_register", comment: ""),
            for: .normal
        )
        signUpButton.addTarget(self, action: #selector(signUpButtonTap), for: .touchUpInside)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signUpButton.heightAnchor.constraint(equalToConstant: 48),
        ])
        
        actionButtonsStackView.addArrangedSubview(signUpButton)
    }
    
    private func setupHasNoPatronymicCheckBox() {
        let patronymicCheckBoxContainer = UIView()
        patronymicCheckBoxContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let patronymicCheckBoxDescriptionLabel = UILabel()
        
        patronymicCheckBoxDescriptionLabel <~ Style.Label.primaryText
        patronymicCheckBoxDescriptionLabel.text = NSLocalizedString("auth_sign_up_has_no_patronymic", comment: "")
        patronymicCheckBoxContainer.addSubview(patronymicCheckBoxDescriptionLabel)
        patronymicCheckBoxDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        patronymicCheckBoxContainer.addSubview(checkboxButton)
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: patronymicCheckBoxContainer.leadingAnchor),
            checkboxButton.topAnchor.constraint(greaterThanOrEqualTo: patronymicCheckBoxContainer.topAnchor),
            checkboxButton.bottomAnchor.constraint(lessThanOrEqualTo: patronymicCheckBoxContainer.bottomAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: patronymicCheckBoxContainer.centerYAnchor),
            patronymicCheckBoxDescriptionLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 9),
            patronymicCheckBoxDescriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: patronymicCheckBoxContainer.trailingAnchor),
            patronymicCheckBoxDescriptionLabel.topAnchor.constraint(equalTo: patronymicCheckBoxContainer.topAnchor, constant: 6),
            patronymicCheckBoxDescriptionLabel.bottomAnchor.constraint(equalTo: patronymicCheckBoxContainer.bottomAnchor, constant: -15),
            patronymicCheckBoxDescriptionLabel.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor)
        ])
        checkboxButton.addTarget(self, action: #selector(patronymicFieldSelected), for: .touchUpInside)
        contentStackView.addArrangedSubview(patronymicCheckBoxContainer)
    }
    
    private func setupFields() {
        lastnameInput.textField.placeholder = NSLocalizedString("auth_sign_up_last_name", comment: "")
        lastnameInput.textField.autocapitalizationType = .words
        lastnameInput.textField.addTarget(self, action: #selector(lastnameInputEditingDidEnd), for: .editingDidEnd)
        contentStackView.addArrangedSubview(lastnameInput)
        lastnameInput.validationRules = [ RequiredValidationRule() ]
        
        firstnameInput.textField.placeholder = NSLocalizedString("auth_sign_up_first_name", comment: "")
        firstnameInput.textField.autocapitalizationType = .words
        firstnameInput.textField.addTarget(self, action: #selector(firstnameInputEditingDidEnd), for: .editingDidEnd)
        contentStackView.addArrangedSubview(firstnameInput)
        firstnameInput.validationRules = [ RequiredValidationRule() ]
        
        patronymicInput.textField.placeholder = NSLocalizedString("auth_sign_up_patronymic_placeholder", comment: "")
        patronymicInput.textField.autocapitalizationType = .words
        patronymicInput.textField.addTarget(self, action: #selector(patronymicInputEditingDidEnd), for: .editingDidEnd)
        contentStackView.addArrangedSubview(patronymicInput)
        
        patronymicInput.textField.isEnabled = !checkboxButton.isSelected
        patronymicInput.validationRules = [ RequiredValidationRule() ]
        setupHasNoPatronymicCheckBox()

        phoneInput.textField.placeholder = NSLocalizedString("auth_sign_up_phone", comment: "")
        phoneInput.showErrorState = false
        phoneInput.textField.keyboardType = .phonePad
        phoneInput.textField.addTarget(self, action: #selector(phoneInputEditingDidEnd), for: .editingDidEnd)
        phoneInput.textField.addTarget(self, action: #selector(phoneInputAllEditingEvents), for: .allEditingEvents)
        contentStackView.addArrangedSubview(phoneInput)
        phoneInput.validationRules = [
            LengthValidationRule(countChars: 18),
            RequiredValidationRule()
        ]

        birthDateInput.textField.placeholder = NSLocalizedString("auth_sign_up_birthday", comment: "")
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.date = Date()
        datePickerView.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
        datePickerView.maximumDate = Date()
        datePickerView.locale = AppLocale.currentLocale
        birthDateInput.textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(birthDatePicked), for: .valueChanged)
        contentStackView.addArrangedSubview(birthDateInput)

        emailInput.validateAsYouType = false
        emailInput.textField.placeholder = NSLocalizedString("auth_sign_up_email", comment: "")
        emailInput.textField.keyboardType = .emailAddress
        emailInput.textField.autocapitalizationType = .none
        emailInput.textField.addTarget(self, action: #selector(emailInputEditingDidEnd), for: .editingDidEnd)
        contentStackView.addArrangedSubview(emailInput)
        emailInput.validationRules = [
            RequiredValidationRule(),
            EmailByDataDetectorValidationRule()
        ]
        
        insuranceNumberInput.textField.placeholder = NSLocalizedString("auth_sign_up_insurance_number_placeholder", comment: "")
        insuranceNumberInput.textField.addTarget(self, action: #selector(insuranceNumberInputEditingDidEnd), for: .editingDidEnd)
        contentStackView.addArrangedSubview(insuranceNumberInput)
    }
    
    private func setupSignUpErrorField() {
        signUpErrorLabel <~ Style.Label.negativeSubhead
        signUpErrorLabel.numberOfLines = 0
        
        errorLabelContainer.addSubview(signUpErrorLabel)
        signUpErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(errorLabelContainer)
        
        errorLabelContainer.isHidden = true

        NSLayoutConstraint.activate([
            signUpErrorLabel.leadingAnchor.constraint(equalTo: errorLabelContainer.leadingAnchor),
            signUpErrorLabel.trailingAnchor.constraint(equalTo: errorLabelContainer.trailingAnchor),
            signUpErrorLabel.topAnchor.constraint(equalTo: errorLabelContainer.topAnchor, constant: 9),
            signUpErrorLabel.bottomAnchor.constraint(equalTo: errorLabelContainer.bottomAnchor, constant: -9)
        ])
    }
    
    private func setupAgreementView() {
        scrollView.addSubview(agreementView)

        agreementView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            agreementView.topAnchor.constraint(
                greaterThanOrEqualTo: contentStackView.bottomAnchor,
                constant: 15
            ),
            agreementView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            agreementView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            agreementView.bottomAnchor.constraint(
                equalTo: actionButtonsStackView.topAnchor,
                constant: -24
            ).with(priority: .defaultLow)
        ])
    }
    
    private func updateTermsOnAgreementView(with linkedText: LinkedText) {
        let links = linkedText.links.map {
            LinkArea(
                text: $0.text,
                link: URL(string: $0.path),
                tapHandler: { [weak self] url in
                    guard let url = url
                    else { return }
                    
                    self?.output.showDocument(url)
                }
            )
        }

        agreementView.set(
            text: linkedText.text,
            userInteractionWithTextEnabled: true,
            links: links,
            handler: .init(
                userAgreementChanged: { [weak self] checked in
                    guard let self = self
                    else { return }
                                        
                    self.registrationUserPersonalInfo.agreementConfirmed = checked
                }
            )
        )
    }
    
    // MARK: - updatedRegistrationUserPersonalInfo
    @objc func lastnameInputEditingDidEnd() {
        registrationUserPersonalInfo.lastname = value(from: lastnameInput)
    }

    @objc func firstnameInputEditingDidEnd() {
        registrationUserPersonalInfo.firstname = value(from: firstnameInput)
    }

    @objc func patronymicInputEditingDidEnd() {
        registrationUserPersonalInfo.patronymic = value(from: patronymicInput)
    }

    @objc func phoneInputEditingDidEnd() {
        registrationUserPersonalInfo.phone = phoneInput.isValid
            ? Phone(
                plain: textFieldController.unformattedString,
                humanReadable: textFieldController.formattedString(from: textFieldController.unformattedString)
            )
            : nil
    }
    
    @objc func phoneInputAllEditingEvents() {
        _ = textFieldController.formattedString(from: textFieldController.unformattedString)
    }
    
    @objc func birthDatePicked() {
        if let datePicker = birthDateInput.textField.inputView as? UIDatePicker {
            let pickedDate = datePicker.date
            let dateString = dateFormatter.string(from: pickedDate)
            
            birthDateInput.textField.text = dateString
            registrationUserPersonalInfo.birthDate = pickedDate
        }
    }
    
    @objc func emailInputEditingDidEnd() {
        registrationUserPersonalInfo.email = value(from: emailInput)
    }
    
    @objc func patronymicFieldSelected() {
        checkboxButton.isSelected.toggle()

        registrationUserPersonalInfo.hasPatronymic = !checkboxButton.isSelected
        patronymicInput.textField.isEnabled = !checkboxButton.isSelected
        
        if checkboxButton.isSelected {
            patronymicInput.textField.text = nil
            registrationUserPersonalInfo.patronymic = nil
        }
        
        patronymicInput.shoudValidate = checkboxButton.isSelected
    }
        
    @objc func insuranceNumberInputEditingDidEnd() {
        registrationUserPersonalInfo.insuranceId = value(from: insuranceNumberInput)
    }
    
    private func value(from textInput: CommonTextInput) -> String? {
        if textInput.isValid {
            if let text = textInput.textField.text {
                return text.isEmpty ? nil : text
            }
            return nil
        }
        
        return nil
    }
    
    // MARK: - ViewController state
    private func update(with state: State) {
        switch state {
            case .loading(let title):
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .loading(.init(
                    title: title,
                    description: nil,
                    icon: nil
                ))
                addRightButton(
                    title: NSLocalizedString("auth_sign_up_chat_nav_item_title", comment: ""),
                    action: output.toChat
                )
                operationStatusView.notify.updateState(state)
            case .failure(title: let title, description: let description):
                navigationItem.rightBarButtonItem = nil
                
                let state: OperationStatusView.State = .info(.init(
                    title: title,
                    description: description,
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
                        action: {
                            self.output.retry()
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
            case .data(let registerTerms):
                operationStatusView.isHidden = true
                scrollView.isHidden = false
                
                if let registerTerms = registerTerms {
                    updateTermsOnAgreementView(with: registerTerms)
                }
                
                addRightButton(
                    title: NSLocalizedString("auth_sign_up_chat_nav_item_title", comment: ""),
                    action: output.toChat
                )
        }
    }
    
    // MARK: - Keyboard notifications handling
    private func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow() {
        bottomContentStackViewConstraint.constant = -Contstatns.contentStackViewBottomOffset
    }
    
    @objc func keyboardWillHide() {
        bottomContentStackViewConstraint.constant = stackViewBottomOffset()
            
    }

    struct Contstatns {
        static let contentStackViewBottomOffset: CGFloat = 15
    }
    
    private func stackViewBottomOffset() -> CGFloat {
        return -(agreementView.frame.height + actionButtonsStackView.frame.height + Contstatns.contentStackViewBottomOffset)
    }
}
