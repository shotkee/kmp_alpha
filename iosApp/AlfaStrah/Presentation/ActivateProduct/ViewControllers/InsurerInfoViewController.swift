//
//  InsurerInfoViewController.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/26/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class InsurerInfoViewController: ViewController {
    private enum Constants {
        static let phoneMask = "+7 ([xxx]) [xxx]-[xx]-[xx]"
    }

    struct Input {
        let stepsCount: Int
        let currentStepIndex: Int
        let minimumDate: Date
        let account: Account?
    }

    struct Output {
        let continueWithInsurerInfo: (InsuranceParticipant) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var lastNameInput: FancyTextInput!
    @IBOutlet private var firstNameInput: FancyTextInput!
    @IBOutlet private var patronymicInput: FancyTextInput!
    @IBOutlet private var phoneInput: FancyTextInput!
    @IBOutlet private var birthDateLabel: UILabel!
    @IBOutlet private var birthDateView: UIView!
    @IBOutlet private var emailInput: FancyTextInput!
    @IBOutlet private var indexInput: FancyTextInput!
    @IBOutlet private var cityInput: FancyTextInput!
    @IBOutlet private var addressInput: FancyTextInput!
    @IBOutlet private var activateButton: RoundEdgeButton!
    @IBOutlet private var productTitleLabel: UILabel!
    @IBOutlet private var stepInfoLabel: UILabel!
    private let keyboardBehavior: KeyboardBehavior = .init()
    private var defaultInsets: UIEdgeInsets = .zero
    private lazy var accessoryActivateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(activateTap(_:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 160, height: 52)
        button <~ Style.Button.ActionRed(title: NSLocalizedString("common_next", comment: ""))
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
        datePicker.locale = AppLocale.currentLocale
        datePicker.minimumDate = self.input.minimumDate
        datePicker.maximumDate = Date()
        return datePicker
    }()

    private lazy var datePickerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 216).with(priority: .required - 1),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        view.isHidden = true
        view.clipsToBounds = true
        return view
    }()

    private var dateDisplayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = AppLocale.currentLocale
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()

    private var inputs: [FancyTextInput] {
        [
            lastNameInput,
            firstNameInput,
            patronymicInput,
            phoneInput,
            emailInput,
            indexInput,
            cityInput,
            addressInput
        ]
    }

    private var isButtonEnabled: Bool {
        let requiredInputs = inputs.filter { $0 !== self.patronymicInput }
        let inputsFilled = requiredInputs.allSatisfy { $0.textField.text?.isEmpty == false }
        return inputsFilled && (birthDateLabel.text?.isEmpty == false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardBehavior.subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardBehavior.unsubscribe()
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:))))
        birthDateLabel <~ Style.Label.primaryText
        productTitleLabel <~ Style.Label.primaryText
        stepInfoLabel <~ Style.Label.primaryText
        productTitleLabel.text = NSLocalizedString("activate_product_product_type", comment: "")
        stepInfoLabel.text = String(
            format: NSLocalizedString("activate_product_step", comment: ""),
            input.currentStepIndex, input.stepsCount
        )
		activateButton.setTitle(NSLocalizedString("common_next", comment: ""), for: .normal)
		activateButton <~ Style.RoundedButton.redBackground
		
        activateButton.addTarget(self, action: #selector(activateTap(_:)), for: .touchUpInside)
        inputs.forEach { input in
            input.textField.inputAccessoryView = self.accessoryActivateButton
        }
        lastNameInput.textFieldPlaceholderText = NSLocalizedString("activate_product_last_name", comment: "")
        lastNameInput.descriptionText = NSLocalizedString("activate_product_last_name", comment: "")
		lastNameInput.textField.font = Style.Font.text
        lastNameInput.updateTextField(text: input.account?.lastName ?? "")
        lastNameInput.onReturnPressed = { [unowned self] _ in
            self.firstNameInput.becomeFirstResponder()
        }
        lastNameInput.onTextDidChange = { [unowned self] _ in
            self.toggleButtonEnabled()
        }

        firstNameInput.textFieldPlaceholderText = NSLocalizedString("activate_product_first_name", comment: "")
        firstNameInput.descriptionText = NSLocalizedString("activate_product_first_name", comment: "")
		firstNameInput.textField.font = Style.Font.text
        firstNameInput.updateTextField(text: input.account?.firstName ?? "")
        firstNameInput.onReturnPressed = { [unowned self] _ in
            self.patronymicInput.becomeFirstResponder()
        }
		
        firstNameInput.onTextDidChange = { [unowned self] _ in
            self.toggleButtonEnabled()
        }

        patronymicInput.textFieldPlaceholderText = NSLocalizedString("activate_product_patronymic", comment: "")
        patronymicInput.descriptionText = NSLocalizedString("activate_product_patronymic", comment: "")
        patronymicInput.updateTextField(text: input.account?.patronymic ?? "")
		patronymicInput.textField.font = Style.Font.text
        patronymicInput.onReturnPressed = { [unowned self] _ in
            self.phoneInput.becomeFirstResponder()
        }
        patronymicInput.onTextDidChange = { [unowned self] _ in
            self.toggleButtonEnabled()
        }

        phoneInput.textFieldPlaceholderText = NSLocalizedString("activate_product_phone_number", comment: "")
        phoneInput.descriptionText = NSLocalizedString("activate_product_phone_number", comment: "")
		phoneInput.textField.font = Style.Font.text
        phoneInput.updateTextField(text: input.account?.phone.humanReadable ?? "")
        phoneInput.onReturnPressed = { [unowned self] _ in
            self.toggleBirthDatePickerAppearance()
        }
        phoneInput.onTextDidChange = { [unowned self] _ in
            self.toggleButtonEnabled()
        }

        birthDateLabel.text = NSLocalizedString("activate_product_birth_date", comment: "")
        if let indexOfBirthDatePicker = stackView.arrangedSubviews.firstIndex(of: birthDateView)?.advanced(by: 1) {
            stackView.insertArrangedSubview(datePickerContainerView, at: indexOfBirthDatePicker)
            birthDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(birthDateTap(_:))))
            birthDateLabel.text = dateDisplayFormatter.string(from: input.account?.birthDate ?? Date())
            datePicker.date = input.account?.birthDate ?? Date()
        }

        emailInput.textFieldPlaceholderText = NSLocalizedString("activate_product_email", comment: "")
        emailInput.descriptionText = NSLocalizedString("activate_product_email", comment: "")
		emailInput.textField.font = Style.Font.text
        emailInput.updateTextField(text: input.account?.email ?? "")
        emailInput.onReturnPressed = { [unowned self] _ in
            self.indexInput.becomeFirstResponder()
        }
        emailInput.onTextDidChange = { [unowned self] _ in
            self.toggleButtonEnabled()
        }

        indexInput.textFieldPlaceholderText = NSLocalizedString("activate_product_zip", comment: "")
        indexInput.descriptionText = NSLocalizedString("activate_product_zip", comment: "")
		indexInput.textField.font = Style.Font.text
        indexInput.onReturnPressed = { [unowned self] _ in
            self.cityInput.becomeFirstResponder()
        }
        indexInput.onTextDidChange = { [unowned self] _ in
            self.toggleButtonEnabled()
        }

        cityInput.textFieldPlaceholderText = NSLocalizedString("activate_product_city", comment: "")
        cityInput.descriptionText = NSLocalizedString("activate_product_city", comment: "")
		cityInput.textField.font = Style.Font.text
        cityInput.onReturnPressed = { [unowned self] _ in
            self.addressInput.becomeFirstResponder()
        }
        cityInput.onTextDidChange = { [unowned self] _ in
            self.toggleButtonEnabled()
        }

        addressInput.textFieldPlaceholderText = NSLocalizedString("activate_product_address", comment: "")
        addressInput.descriptionText = NSLocalizedString("activate_product_address", comment: "")
		addressInput.textField.font = Style.Font.text
        addressInput.onReturnPressed = { textField in
            textField.resignFirstResponder()
        }
        addressInput.onTextDidChange = { [unowned self] _ in
            self.toggleButtonEnabled()
        }

        phoneInput.textMask = Constants.phoneMask
        phoneInput.textField.keyboardType = .phonePad
        emailInput.textField.keyboardType = .emailAddress
        indexInput.textField.keyboardType = .numberPad
        toggleButtonEnabled()

        keyboardBehavior.animations = { [weak self] frame, _, _ in
            guard let self = self else { return }

            let frameInView = self.scrollView.convert(frame, from: nil)
            let bottomInset = max(self.scrollView.bounds.maxY - frameInView.minY, 0)
            var insets = self.defaultInsets
            insets.bottom = max(insets.bottom, bottomInset)
            self.scrollView.contentInset = insets
            self.scrollView.scrollIndicatorInsets = insets
            self.inputs.forEach { input in
                if input.isFirstResponder {
                    self.scrollView.scrollRectToVisible(input.frame, animated: true)
                }
            }
            self.activateButton.alpha = frame.height == 0 ? 0 : 1
        }
    }

    @objc private func dateSelected(_ datePicker: UIDatePicker) {
        birthDateLabel.text = dateDisplayFormatter.string(from: datePicker.date)
        toggleButtonEnabled()
    }

    @objc private func birthDateTap(_ sender: UITapGestureRecognizer?) {
        toggleBirthDatePickerAppearance()
    }

    @objc private func activateTap(_ sender: UIButton) {
        guard
            let lastName = lastNameInput.textField.text,
            let firstName = firstNameInput.textField.text,
            let phoneString = phoneInput.textField.text,
            let birthDateString = birthDateLabel.text,
            let email = emailInput.textField.text,
            let index = indexInput.textField.text,
            let city = indexInput.textField.text,
            let address = addressInput.textField.text,
            let date = dateDisplayFormatter.date(from: birthDateString)
        else {
            return
        }

        let insurer = InsuranceParticipant(
            fullName: firstName + " " + lastName,
            firstName: firstName,
            lastName: lastName,
            patronymic: patronymicInput.textField.text,
            birthDate: date,
            birthDateNonISO: date,
            sex: nil,
            contactInformation: "email:\(email), phone:\(phoneString)",
            fullAddress: "\(city), \(address), \(index)"
        )
        output.continueWithInsurerInfo(insurer)
    }

    @objc private func hideKeyboard(_ sender: UITapGestureRecognizer) {
        inputs.forEach { input in
            input.resignFirstResponder()
        }
    }

    private func toggleButtonEnabled() {
        activateButton.isEnabled = isButtonEnabled
        accessoryActivateButton.isEnabled = isButtonEnabled
    }

    private func toggleBirthDatePickerAppearance() {
        UIView.animate(withDuration: 0.25) {
            self.datePickerContainerView.isHidden.toggle()
            self.datePickerContainerView.alpha = self.datePickerContainerView.isHidden ? 0 : 1
        }
    }
}
