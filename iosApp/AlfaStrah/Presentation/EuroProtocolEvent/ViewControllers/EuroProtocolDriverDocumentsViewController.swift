//
//  EuroProtocolDriverDocumentsViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 02.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class EuroProtocolDriverDocumentsViewController: EuroProtocolBaseScrollViewController {
    struct Output {
        let nextScreen: () -> Void
        let setDriverInfo: (_ info: DriverDocuments, @escaping (Result<String, EuroProtocolServiceError>) -> Void) -> Void
    }

    struct Input {
        let dataSource: DriverDocumentsInfo
    }

    var output: Output!
    var input: Input!

    enum InputType: CaseIterable {
        case driverLicense
        case startDateDriverLicense
        case endDateDriverLicense
        case geoPlace
        case phone
        case categoryDriverLicense

        var title: String {
            switch self {
                case .driverLicense:
                    return NSLocalizedString("insurance_euro_protocol_driver_license_number_input_title", comment: "")
                case .startDateDriverLicense:
                    return NSLocalizedString("insurance_euro_protocol_driver_license_start_date_input_title", comment: "")
                case .endDateDriverLicense:
                    return NSLocalizedString("insurance_euro_protocol_driver_license_end_date_input_title", comment: "")
                case .geoPlace:
                    return NSLocalizedString("insurance_euro_protocol_driver_license_geoplace_input_title", comment: "")
                case .phone:
                    return NSLocalizedString("insurance_euro_protocol_driver_license_phone_input_title", comment: "")
                case .categoryDriverLicense:
                    return NSLocalizedString("insurance_euro_protocol_driver_license_categoty_type_input_title", comment: "")
            }
        }

        func valueText(dataSource: DriverDocumentsInfo) -> String? {
            switch self {
                case .driverLicense:
                    return dataSource.driverLicense?.description
                case .startDateDriverLicense:
                    guard let date = dataSource.startDateDriverLicense else { return nil }

                    return AppLocale.dateString(date)
                case .endDateDriverLicense:
                    guard let date = dataSource.endDateDriverLicense else { return nil }

                    return AppLocale.dateString(date)
                case .geoPlace:
                    return dataSource.address
                case .phone:
                    return dataSource.phone
                case .categoryDriverLicense:
                    guard let categoryDriverLicense = dataSource.categoryDriverLicense else { return nil }

                    return categoryDriverLicense.map { $0.title }.joined(separator: ", ")
            }
        }

        func errorText(dataSource: DriverDocumentsInfo) -> String? {
            switch self {
                case .driverLicense:
                    return dataSource.driverLicenseErrorText
                case .startDateDriverLicense:
                    return dataSource.startDateDriverLicenseErrorText
                case .endDateDriverLicense:
                    return dataSource.endDateDriverLicenseErrorText
                case .geoPlace:
                    return dataSource.addressErrorText
                case .phone:
                    return dataSource.phoneErrorText
                case .categoryDriverLicense:
                    return dataSource.categoryDriverLicenseErrorText
            }
        }
    }

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 24

        return stack
    }()

    private lazy var infoLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ Style.Label.secondaryText
        label.textAlignment = .left
        label.numberOfLines = 0

        return label
    }()

    private lazy var nextButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_continue", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var driverDocumentsInfo: DriverDocumentsInfo = input.dataSource

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_driver_license_title", comment: "")
        infoLabel.text = NSLocalizedString("insurance_euro_protocol_driver_license_info", comment: "")

        let cardStack: UIStackView = .init(arrangedSubviews: InputType.allCases.map { createInputView($0) })
        cardStack.axis = .vertical
        let cardView = CardView(contentView: cardStack)

        scrollContentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(infoLabel)
        contentStackView.addArrangedSubview(cardView)
        addBottomButtonsContent(nextButton)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 18),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func updateUI() {
        nextButton.isEnabled = driverDocumentsInfo.allPropertiesAreNotNull
    }

    private func updateContentStack() {
        let cardStack: UIStackView = .init(arrangedSubviews: InputType.allCases.map { createInputView($0) })
        cardStack.axis = .vertical

        let cardView = CardView(contentView: cardStack)

        contentStackView.subviews.forEach { $0.removeFromSuperview() }
        contentStackView.addArrangedSubview(cardView)
    }

    private func createInputView(_ type: InputType) -> SmallValueCardView {
        let infoView = SmallValueCardView()
        infoView.set(
            title: type.title,
            placeholder: type.title,
            value: type.valueText(dataSource: driverDocumentsInfo),
            error: type.errorText(dataSource: driverDocumentsInfo),
            showSeparator: true
        )

        infoView.tapHandler = { [weak self] in
            self?.inputTap(type, infoView: infoView)
        }

        return infoView
    }

    private func inputTap(_ type: InputType, infoView: SmallValueCardView) {
        switch type {
            case .driverLicense:
                openDriverLicenseNumberInputBottomViewController(with: infoView)
            case .startDateDriverLicense:
                openStartDateInputBottomViewController(with: infoView)
            case .endDateDriverLicense:
                openEndDateInputBottomViewController(with: infoView)
            case .geoPlace:
                openGeoPlaceTextInputBottomViewController(with: infoView)
            case .phone:
                openPhoneInputBottomViewController(with: infoView)
            case .categoryDriverLicense:
                openDriverCategorySelectedBottomViewContrller(with: infoView)
        }
    }

    private func updateInfoView(with infoView: SmallValueCardView, type: InputType) {
        infoView.update(value: type.valueText(dataSource: driverDocumentsInfo))
        updateUI()
    }

    private func openDriverLicenseNumberInputBottomViewController(with infoView: SmallValueCardView) {
        let controller: InputBottomViewController = .init()
        container?.resolve(controller)

        let seriaInput = InputBottomViewController.InputObject(
            text: driverDocumentsInfo.driverLicense?.series,
            placeholder: NSLocalizedString("osago_prolongation_driver_license_seria_placeholder", comment: ""),
            keyboardType: .default,
            validationRule: [ RequiredValidationRule() ]
        )

        let numberInput = InputBottomViewController.InputObject(
            text: driverDocumentsInfo.driverLicense?.number,
            placeholder: NSLocalizedString("osago_prolongation_driver_license_number_placeholder", comment: ""),
            keyboardType: .numberPad,
            validationRule: [ RequiredValidationRule() ]
        )

        controller.input = .init(
            title: NSLocalizedString("osago_prolongation_driver_license_title", comment: ""),
            infoText: NSLocalizedString("insurance_euro_protocol_driver_license_number_input_info", comment: ""),
            inputs: [ seriaInput, numberInput ]
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            done: { [unowned self] result in
                let driverLicense = SeriesAndNumberDocument(series: result[seriaInput.id] ?? "", number: result[numberInput.id] ?? "")
                self.driverDocumentsInfo.driverLicense = driverLicense
                self.updateInfoView(with: infoView, type: .driverLicense)
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func openStartDateInputBottomViewController(with infoView: SmallValueCardView) {
        openDateInputBottomViewController(
            with: infoView,
            title: InputType.startDateDriverLicense.title,
            minimumDate: Calendar.current.date(byAdding: .year, value: -20, to: Date()),
            maximumDate: Date()
        ) { [unowned self] date in
            self.driverDocumentsInfo.startDateDriverLicense = date
            self.updateInfoView(with: infoView, type: .startDateDriverLicense)
        }
    }

    private func openEndDateInputBottomViewController(with infoView: SmallValueCardView) {
        openDateInputBottomViewController(
            with: infoView,
            title: InputType.endDateDriverLicense.title,
            minimumDate: Date(),
            maximumDate: Calendar.current.date(byAdding: .year, value: 20, to: Date())
        ) { [unowned self] date in
            self.driverDocumentsInfo.endDateDriverLicense = date
            self.updateInfoView(with: infoView, type: .endDateDriverLicense)
        }
    }

    private func openGeoPlaceTextInputBottomViewController(with infoView: SmallValueCardView) {
        let controller: TextAreaInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: InputType.geoPlace.title,
            description: nil,
            textInputTitle: nil,
            textInputPlaceholder: NSLocalizedString("insurance_euro_protocol_driver_license_geoplace_input_description", comment: ""),
            initialText: infoView.getValue(),
            validationRules: [ ],
            showValidInputIcon: true,
            keyboardType: .default,
            autocapitalizationType: .none,
            charsLimited: .unlimited,
            showMaxCharsLimit: false
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            text: { [unowned self] text in
                self.driverDocumentsInfo.address = text
                self.updateInfoView(with: infoView, type: .geoPlace)
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func openPhoneInputBottomViewController(with infoView: SmallValueCardView) {
        openTextInputBottomViewController(
            with: infoView,
            title: InputType.phone.title,
            description: NSLocalizedString("sos_phonecall_description", comment: ""),
            placeholder: NSLocalizedString("sos_phonecall_placeholder", comment: ""),
            keyboardType: .default
        ) { [unowned self] text in
            self.driverDocumentsInfo.phone = text
            self.updateInfoView(with: infoView, type: .phone)
        }
    }

    private func openDriverCategorySelectedBottomViewContrller(with infoView: SmallValueCardView) {
        let controller: MultipleValuePickerBottomViewController = .init()
        container?.resolve(controller)

        let dataSource: [SelectableItem] = EuroProtocolLicenseCategory.allCases.map { category -> SelectableItem in
            if let categoryDriverLicense = driverDocumentsInfo.categoryDriverLicense, categoryDriverLicense.contains(category) {
                return DriverLicenseCategorySelectable(title: category.longTitle, isSelected: true)
            }
            return DriverLicenseCategorySelectable(title: category.longTitle, isSelected: false)
        }

        controller.input = .init(
            title: NSLocalizedString("insurance_euro_protocol_driver_license_categoty_type_input_title", comment: ""),
            dataSource: dataSource,
            isMultiSelectAllowed: true
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            done: { [unowned self] selected in
                let selectedTitles = selected.map { $0.title }
                let selectedArray = EuroProtocolLicenseCategory.allCases.filter {
                    selectedTitles.contains($0.longTitle)
                }

                self.driverDocumentsInfo.categoryDriverLicense = selectedArray
                self.updateInfoView(with: infoView, type: .categoryDriverLicense)
                self.dismiss(animated: true)
            }
        )
        showBottomSheet(contentViewController: controller)
    }

    private func openDateInputBottomViewController(
        with infoView: SmallValueCardView,
        title: String,
        currentDate: Date = Date(),
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        completion: @escaping (Date) -> Void
    ) {
        let controller: DateInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: title,
            mode: .date,
            date: currentDate,
            maximumDate: maximumDate,
            minimumDate: minimumDate
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },

            selectDate: { [unowned self] date in
                completion(date)
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func openTextInputBottomViewController(
        with infoView: SmallValueCardView,
        title: String,
        description: String,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        completion: @escaping (String) -> Void
    ) {
        let controller: InputBottomViewController = .init()
        container?.resolve(controller)

        let textInput = InputBottomViewController.InputObject(
            text: infoView.getValue(),
            placeholder: placeholder,
            keyboardType: keyboardType,
            validationRule: [ RequiredValidationRule() ]
        )

        controller.input = .init(
            title: title,
            infoText: description,
            inputs: [ textInput ]
        )

        controller.output = .init(
            close: { [unowned self] in
                self.dismiss(animated: true)
            },
            done: { [unowned self] result in
                completion(result[textInput.id] ?? "")
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    @objc private func nextButtonAction() {
        guard let driverDocuments = driverDocumentsInfo.driverDocuments else { return }

        clearValidationErrorText()
        let hide = showLoadingIndicator(message: nil)
        output.setDriverInfo(driverDocuments) { [weak self] result in
            hide(nil)
            switch result {
                case .success:
                    self?.output.nextScreen()
                case .failure(let error):
                    self?.handleError(error)
            }
        }
    }

    // MARK: - Handle Error

    @discardableResult
    override func handleError(_ error: Error) -> Bool {
        guard !super.handleError(error) else { return true }

        switch error {
            case EuroProtocolServiceError.sdkError(.validationErrors( _, _, errors: let errors)):
                errors.forEach { validationError in
                    switch validationError {
                        case .invalidLicenseSeriesCount( _, description: let description),
                             .invalidLicenseNumberCount( _, description: let description):

                            if let driverLicenseErrorText = driverDocumentsInfo.driverLicenseErrorText {
                                driverDocumentsInfo.driverLicenseErrorText = driverLicenseErrorText + ", " + description
                            } else {
                                driverDocumentsInfo.driverLicenseErrorText = description
                            }
                        case .emptyLicenseCategoryList( _, description: let description):
                            driverDocumentsInfo.categoryDriverLicenseErrorText = description
                        case .invalidLicenseIssueDate( _, description: let description):
                            driverDocumentsInfo.startDateDriverLicenseErrorText = description
                        case .invalidLicenseExpiryDate( _, description: let description):
                            driverDocumentsInfo.endDateDriverLicenseErrorText = description
                        case .invalidDriverAddress( _, description: let description):
                            driverDocumentsInfo.addressErrorText = description
                        case .invalidDriverPhone( _, description: let description):
                            driverDocumentsInfo.phoneErrorText = description
                        default:
                            processError(error)
                    }
                }
            default:
                processError(error)
        }
        updateContentStack()

        return true
    }

    private func clearValidationErrorText() {
        driverDocumentsInfo.driverLicenseErrorText = nil
        driverDocumentsInfo.startDateDriverLicenseErrorText = nil
        driverDocumentsInfo.endDateDriverLicenseErrorText = nil
        driverDocumentsInfo.addressErrorText = nil
        driverDocumentsInfo.phoneErrorText = nil
        driverDocumentsInfo.categoryDriverLicenseErrorText = nil
    }
}
