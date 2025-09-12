//
//  CostRecoveryFlow.swift
//  AlfaStrah
//
//  Created by vit on 27.12.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

// swiftlint:disable file_length
class DmsCostRecoveryFlow: BaseFlow,
                           DmsCostRecoveryServiceDependency,
                           AttachmentServiceDependency {
    var dmsCostRecoveryService: DmsCostRecoveryService!
    var attachmentService: AttachmentService!
    
    private let storyboard = UIStoryboard(name: "DmsCostRecovery", bundle: nil)
    private var dmsCostRecoveryFormViewController: DmsCostRecoveryFormViewController?
    
    private lazy var documentSelectionBehavior = DocumentPickerBehavior()
    private var photosUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    
    private lazy var passportUpdatedSubscriptions: Subscriptions<Passport> = Subscriptions()
    private lazy var requisitesUpdatedSubscriptions: Subscriptions<Requisites> = Subscriptions()
    private lazy var additionalInfoUpdatedSubscriptions: Subscriptions<AdditionalInfo> = Subscriptions()
    private lazy var applicantPersonalInfoUpdatedSubscriptions: Subscriptions<ApplicantPersonalInfo> = Subscriptions()
    private lazy var applicantInfoFilledSubscriptions: Subscriptions<Bool> = Subscriptions()
    
    private lazy var insuranceEventApplicationInfoUpdatedSubscriptions: Subscriptions<InsuranceEventApplicationInfo> = Subscriptions()
    private lazy var insuranceEventInfoFilledSubscriptions: Subscriptions<Bool> = Subscriptions()
    private lazy var applicationConfirmedSubscriptions: Subscriptions<DmsCostRecoveryApplicationResponse> = Subscriptions()
    
    private var necessaryConditionsViewControllerState: DmsCostRecoveryNecessaryConditionsViewController.State = .loading
    private var insuranceId: String?
    
    // data from backend
    private var dmsCostRecoveryResult: DmsCostRecoveryData?
    private var dmsCostRecoveryApplicationResponse: DmsCostRecoveryApplicationResponse?
    
    private struct ApplicantPersonalInfo {
        var fullname: String?
        var birthday: Date?
        var policyNumber: String?
        var serviceNumber: String?
        var phone: Phone?
        var email: String?
        
        var isFilled: Bool {
            let values: [Any?] = [
                fullname,
                birthday,
                policyNumber,
                phone,
                email
            ]
            return !values.contains { $0 == nil }
        }
    }
    
    private var applicantPersonalInfo: ApplicantPersonalInfo = .init() {
        didSet {
            applicantPersonalInfoUpdatedSubscriptions.fire(applicantPersonalInfo)
            applicantInfoFilledSubscriptions.fire(applicantInfoFilled)
            anyInfoFilled = true
        }
    }
    
    private struct Passport {
        var series: String?
        var number: String?
        var issuer: String?
        var issueDate: Date?
        var birthPlace: String?
        var citizenship: String?
        
        var isFilled: Bool {
            let values: [Any?] = [
                series,
                number,
                issuer,
                issueDate,
                birthPlace,
                citizenship
            ]
            return !values.contains { $0 == nil }
        }
        init() { }
        init(from passport: DmsCostRecoveryPassport) {
            self.series = passport.series
            self.number = passport.number
            self.issuer = passport.issuer
            self.issueDate = passport.issueDate
            self.birthPlace = passport.birthPlace
            self.citizenship = passport.citizenship
        }
    }
    
    private var passport: Passport = .init() {
        didSet {
            passportUpdatedSubscriptions.fire(passport)
            applicantInfoFilledSubscriptions.fire(applicantInfoFilled)
            anyInfoFilled = true
        }
    }
    
    struct Requisites {
        var bank: DmsCostRecoveryBank?
        var accountNumber: String?
        
        var isFilled: Bool {
            let values: [Any?] = [
                bank,
                accountNumber
            ]
            return !values.contains { $0 == nil }
        }
    }
    
    private var requisites: Requisites = .init() {
        didSet {
            applicantInfoFilledSubscriptions.fire(applicantInfoFilled)
            requisitesUpdatedSubscriptions.fire(requisites)
            anyInfoFilled = true
        }
    }
    
    struct AdditionalInfo {
        enum Kind: Int
        {
            case rfCitizen = 0
            case nonResident = 1
        }
        
        struct RFCitizen {
            var snils: String?
            var inn: String?
            
            var isFilled: Bool {
                let values: [Any?] = [
                    snils,
                    inn
                ]
                return values.contains { $0 != nil }
            }
        }
        
        struct NonResident {
            var migrationCardNumber: String?
            var residentialAddress: String?
            
            var isFilled: Bool {
                let values: [Any?] = [
                    migrationCardNumber,
                    residentialAddress
                ]
                return values.contains { $0 != nil }
            }
        }
        
        var kind: AdditionalInfo.Kind = .rfCitizen
        var rfCitizen: RFCitizen = .init()
        var nonResident: NonResident = .init()
        
        var isFilled: Bool {
            switch kind {
                case .rfCitizen:
                    return rfCitizen.isFilled
                case .nonResident:
                    return nonResident.isFilled
            }
        }
        
    }
    
    private var additionalInfo: AdditionalInfo = .init() {
        didSet {
            additionalInfoUpdatedSubscriptions.fire(additionalInfo)
            anyInfoFilled = true
        }
    }
    
    private var applicantInfoFilled: Bool {
        return passport.isFilled
            && requisites.isFilled
            && applicantPersonalInfo.isFilled
    }
    
    private var selectedInsuredPerson: DmsCostRecoveryInsuredPerson? {
        didSet {
            insuranceEventInfoFilledSubscriptions.fire(insuranceEventInfoFilled)
            anyInfoFilled = true
        }
    }
    
    struct InsuranceEventApplicationInfo {
        var country: String?
        var date: Date?
        var medicalService: DmsCostRecoveryMedicalService?
        var reason: String?
        var expensesAmount: String?
        var currency: DmsCostRecoveryCurrency?
    
        var isFilled: Bool {
            let values: [Any?] = [
                country,
                date,
                medicalService,
                reason,
                expensesAmount,
                currency
            ]
            return !values.contains { $0 == nil }
        }
    }
    
    private var insuranceEventApplicationInfo: InsuranceEventApplicationInfo = .init() {
        didSet {
            insuranceEventApplicationInfoUpdatedSubscriptions.fire(insuranceEventApplicationInfo)
            insuranceEventInfoFilledSubscriptions.fire(insuranceEventInfoFilled)
            anyInfoFilled = true
        }
    }
    
    private var insuranceEventInfoFilled: Bool {
        return selectedInsuredPerson != nil
            && insuranceEventApplicationInfo.isFilled
    }
    
    var anyInfoFilled: Bool = false
    
    // MARK: - Start flow
    func start(insuranceId: String) {
        self.insuranceId = insuranceId
        
        let viewController = createDmsCostRecoveryNecessaryConditionsViewController()
        
        createAndShowNavigationController(
            viewController: viewController,
            mode: .modal
        )
        necessaryConditionsViewControllerState = .loading
        viewController.notify.changed()
        
        dmsCostRecoveryService.dmsCostRecoveryData(insuranceId: insuranceId) { result in
            switch result {
                case .success(let data):
                    self.dmsCostRecoveryResult = data
                    
                    self.applicantPersonalInfo = .init(
                        fullname: data.applicantPersonalInfo.fullname,
                        birthday: data.applicantPersonalInfo.birthday,
                        policyNumber: data.applicantPersonalInfo.policyNumber,
                        serviceNumber: data.applicantPersonalInfo.serviceNumber,
                        phone: data.applicantPersonalInfo.phone,
                        email: data.applicantPersonalInfo.email
                    )
                    
                    if data.insuredPersons.count == 1 {
                        self.selectedInsuredPerson = data.insuredPersons[safe: 0]
                    }
                    
                    if let passport = data.passport {
                        self.passport = Passport(from: passport)
                    }
                    
                    if let requisites = data.requisites {
                        self.requisites = Requisites(bank: requisites.bank, accountNumber: requisites.accountNumber)
                    }
                    
                    if let additionalInfo = data.additionalInfo {
                        switch additionalInfo.citizenship {
                            case .citizen:
                                self.additionalInfo = AdditionalInfo(
                                    kind: .rfCitizen,
                                    rfCitizen: AdditionalInfo.RFCitizen(
                                        snils: data.additionalInfo?.snils,
                                        inn: data.additionalInfo?.inn
                                    )
                                )
                            case .nonResident:
                                self.additionalInfo = AdditionalInfo(
                                    kind: .nonResident,
                                    nonResident: AdditionalInfo.NonResident(
                                        migrationCardNumber: data.additionalInfo?.migrationCardNumber,
                                        residentialAddress: data.additionalInfo?.residentialAddress
                                    )
                                )
                        }
                    }
                    
                    self.necessaryConditionsViewControllerState = .data(data.instruction)
                case .failure:
                    self.necessaryConditionsViewControllerState = .failure
            }
            viewController.notify.changed()
        }
    }
    
    private func createDmsCostRecoveryNecessaryConditionsViewController() -> DmsCostRecoveryNecessaryConditionsViewController{
        let viewController: DmsCostRecoveryNecessaryConditionsViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.addCloseButton(position: .right) { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        
        viewController.input = .init(
            getState: { return self.necessaryConditionsViewControllerState }
        )
        
        viewController.output = .init(
            startedForm: showDmsCostRecoveryForm,
            passToInsurancePlan: { url in
                WebViewer.openDocument(
                    url,
                    from: viewController
                )
            },
            goToChat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            retryToGetData: { [weak viewController, weak self] in
                guard let self = self,
                      let insuranceId = self.insuranceId,
                      let viewController = viewController
                else { return }
                
                self.necessaryConditionsViewControllerState = .loading
                viewController.notify.changed()
                
                self.dmsCostRecoveryService.dmsCostRecoveryData(insuranceId: insuranceId) { result in
                    switch result {
                        case .success(let data):
                            self.necessaryConditionsViewControllerState = .data(data.instruction)
                        case .failure(let error):
                            self.necessaryConditionsViewControllerState = .failure
                    }
                    viewController.notify.changed()
                }
            }
        )
        
        return viewController
    }
    
    private func showDmsCostRecoveryForm() {
        let viewController: DmsCostRecoveryFormViewController = storyboard.instantiate()
        dmsCostRecoveryFormViewController = viewController
        
        container?.resolve(viewController)

        viewController.addBackButton {
            if viewController.getCurrentPageIndex() != 0 {
                self.dmsCostRecoveryFormViewController?.showPreviousPage()
                return
            }
            
            self.navigationController?.popViewController(animated: true)
        }

        viewController.addCloseButton(position: .right) { [weak viewController] in
            guard let viewController = viewController
            else { return }
            
            let dismiss = { [weak viewController] () -> Void in
                viewController?.dismiss(animated: true)
            }
            
            if self.anyInfoFilled {
                self.showQuitAlert(
                    from: viewController,
                    onConfirm: dismiss
                )
            } else {
                dismiss()
            }
        }
        
        viewController.input = .init(
            viewControllers: [
                createDmsCostRecoveryApplicantInfoViewController(),
                createDmsCostRecoveryInsuredPersonInfoViewController(),
                createDmsCostRecoveryApplicationPreviewViewController(),
                createDmsCostRecoveryFilesUploadViewController()
            ]
        )
        
        createAndShowNavigationController(
            viewController: viewController,
            mode: .push
        )
    }
    
    private func showQuitAlert(
        from: ViewController,
        onConfirm: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: NSLocalizedString("dms_cost_recovery_exit_alert_title", comment: ""),
            message: NSLocalizedString("dms_cost_recovery_exit_alert_message", comment: ""),
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(
            title: NSLocalizedString("common_quit", comment: ""),
            style: .default
        ) { _ in
            onConfirm()
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("common_cancel_button", comment: ""),
            style: .cancel
        )
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        from.present(
            alert,
            animated: true
        )
    }
    
    // MARK: - First step
    private func createDmsCostRecoveryApplicantInfoViewController() -> DmsCostRecoveryApplicantInfoViewController {
        let viewController: DmsCostRecoveryApplicantInfoViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.input = .init(
            personalInfoFilled: applicantPersonalInfo.isFilled,
            passportFilled: passport.isFilled,
            requisitesFilled: requisites.isFilled,
            additionalInfoFilled: additionalInfo.isFilled,
            stepDataFilled: applicantInfoFilled
        )
        
        viewController.output = .init(
            nextButtonTap: {
                self.dmsCostRecoveryFormViewController?.showNextPage()
            },
            personalInfo: {
                let viewController = self.createDmsCostRecoveryApplicantPersonalInfoViewController()
                self.createAndShowNavigationController(
                    viewController: viewController,
                    mode: .push
                )
            },
            bankDetails: {
                let viewController = self.createDmsCostRecoveryBankDetailsViewController()
                
                self.createAndShowNavigationController(
                    viewController: viewController,
                    mode: .push
                )
            },
            passportDataTap: {
                let viewController = self.createDmsCostRecoveryPassportDataViewController()
                self.createAndShowNavigationController(
                    viewController: viewController,
                    mode: .push
                )
            },
            additionalInfoTap: {
                let viewController = self.createDmsCostRecoveryAdditionalInfoViewController()
                self.createAndShowNavigationController(
                    viewController: viewController,
                    mode: .push
                )
            }
        )
        requisitesUpdatedSubscriptions
            .add { [weak viewController] requisites in
                viewController?.notify.requisitesFilled(requisites.isFilled)
            }
            .disposed(by: viewController.disposeBag)
        
        applicantPersonalInfoUpdatedSubscriptions
            .add { [weak viewController] applicantPersonalInfo in
                viewController?.notify.personalInfoFilled(applicantPersonalInfo.isFilled)
            }
            .disposed(by: viewController.disposeBag)
        
        passportUpdatedSubscriptions
            .add { [weak viewController] passport in
                viewController?.notify.isPassportFilledUpdated(passport.isFilled)
            }
            .disposed(by: viewController.disposeBag)
        
        additionalInfoUpdatedSubscriptions
            .add { [weak viewController] additionalInfo in
                viewController?.notify.isAdditionalInfoFilledUpdated(additionalInfo.isFilled)
            }
            .disposed(by: viewController.disposeBag)
        
        applicantInfoFilledSubscriptions
            .add(viewController.notify.stepDataFilled)
            .disposed(by: viewController.disposeBag)
        
        return viewController
    }
        
    private func createDmsCostRecoveryApplicantPersonalInfoViewController() -> DmsCostRecoveryEditableSectionsViewController {
        guard dmsCostRecoveryResult?.applicantPersonalInfo != nil
        else { return  DmsCostRecoveryEditableSectionsViewController() }
        
        let viewController: DmsCostRecoveryEditableSectionsViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        let birthdayFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = AppLocale.currentLocale
            dateFormatter.dateFormat = "dd.MM.yyyy"
            return dateFormatter
        }()
            
        func items() -> [SectionsCardView.Item] {
            return [
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_personal_info_fullname_title", comment: ""),
                    placeholder: "",
                    value: self.applicantPersonalInfo.fullname,
                    icon: .empty,
                    isEnabled: true,
                    tapHandler: nil
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_personal_info_birthday_title", comment: ""),
                    placeholder: "",
                    value: birthdayFormatter.string(from: self.applicantPersonalInfo.birthday ?? Date()),
                    icon: .empty,
                    isEnabled: true,
                    tapHandler: nil
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_personal_info_policy_number_title", comment: ""),
                    placeholder: "",
                    value: self.applicantPersonalInfo.policyNumber,
                    icon: .empty,
                    isEnabled: true,
                    tapHandler: nil
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_personal_info_service_number_title", comment: ""),
                    placeholder: "",
                    value: self.applicantPersonalInfo.serviceNumber,
                    icon: .empty,
                    isEnabled: true,
                    tapHandler: nil
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_personal_info_phone_number_title", comment: ""),
                    placeholder: "",
                    value: self.applicantPersonalInfo.phone?.humanReadable,
                    icon: .empty,
                    isEnabled: true,
                    tapHandler: nil
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_personal_info_email", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_personal_info_email", comment: ""),
                    value: self.applicantPersonalInfo.email,
                    icon: .rightArrow,
                    isEnabled: true,
                    tapHandler: {
                        self.openEmailInputBottomViewController(
                            from: viewController,
                            initialEmailText: self.applicantPersonalInfo.email ?? "",
                            completion: { [weak viewController] email in
                                self.applicantPersonalInfo.email = email
                                
                                self.anyInfoFilled = true
                                viewController?.notify.updateItems(self.applicantPersonalInfo.isFilled)
                            }
                        )
                    }
                )
            ]
        }
        
        viewController.input = .init(
            title: NSLocalizedString("dms_cost_recovery_applicant_info", comment: ""),
            filled: self.applicantPersonalInfo.isFilled,
            items: items
        )
        
        viewController.output = .init(
            actionButtonTap: {
                self.navigationController?.popViewController(animated: true)
            }
        )

        return viewController
    }
    
    private func openCountryInputBottomViewController(
        from: UIViewController,
        initialText: String?,
        completion: @escaping (String) -> Void
    ) {
        let controller = CommonBottomViewController()
        
        controller.input = .init(
            title: NSLocalizedString("dms_cost_recovery_insurance_event_country_input_title", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_country_input_request", comment: ""),
            initialText: initialText,
            keyboardType: .default,
            autocapitalizationType: .sentences,
            validationRules: [
                RequiredValidationRule(),
                LengthValidationRule(minChars: 0, maxChars: 250)
            ],
            maxCharacterCount: .limited(250),
            preventInputOnLimit: true
        )
        
        controller.output = .init(
            completion: { [weak from] country in
                completion(country)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
    
    private func openApplicationTypeInputBottomViewController(
        from: UIViewController,
        initialText: String?,
        completion: @escaping (String) -> Void
    ) {
        let controller = CommonBottomViewController()
        
        controller.input = .init(
            title: NSLocalizedString("dms_cost_recovery_insurance_event_application_type_input_title", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_application_type_input_request", comment: ""),
            initialText: initialText,
            keyboardType: .default,
            autocapitalizationType: .sentences,
            validationRules: [
                RequiredValidationRule(),
                LengthValidationRule(minChars: 0, maxChars: 250)
            ],
            maxCharacterCount: .limited(250),
            preventInputOnLimit: true
        )
        
        controller.output = .init(
            completion: { [weak from] type in
                completion(type)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
    
    private func openApplicationReasonInputBottomViewController(
        from: UIViewController,
        initialText: String?,
        completion: @escaping (String) -> Void
    ) {
        let controller = CommonBottomViewController()
        
        controller.input =  .init(
            title: NSLocalizedString("dms_cost_recovery_insurance_event_application_reason_input_title", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_application_reason_input_request", comment: ""),
            initialText: initialText,
            keyboardType: .default,
            autocapitalizationType: .sentences,
            validationRules: [
                RequiredValidationRule(),
                LengthValidationRule(maxChars: 400)
            ],
            maxCharacterCount: .limited(400),
            preventInputOnLimit: true
        )
        
        controller.output = .init(
            completion: { [weak from] reason in
                completion(reason)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
        
    private func openApplicationCurrencyInputBottomViewController(
        from: UIViewController,
        initialText: String?,
        completion: @escaping (String) -> Void
    ) {
        let controller = CommonBottomViewController()
        
        controller.input =  .init(
            title: NSLocalizedString("dms_cost_recovery_insurance_event_currency_input_title", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_currency_input_request", comment: ""),
            initialText: initialText,
            keyboardType: .asciiCapable,
            autocapitalizationType: .allCharacters,
            validationRules: [
                RequiredValidationRule(),
                LengthValidationRule(countChars: 3)
            ],
            maxCharacterCount: .limited(3),
            preventInputOnLimit: true
        )
        
        controller.output = .init(
            completion: { [weak from] currency in
                completion(currency)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }

    private func openApplicationDateInputBottomViewController(
        from: UIViewController,
        ininitialDate: Date?,
        completion: @escaping (Date) -> Void
    ) {
        let controller: DateInputBottomViewController = .init()
        container?.resolve(controller)

        let now = Date()
        
        controller.input = .init(
            title: NSLocalizedString("dms_cost_recovery_insurance_event_application_date_input_title", comment: ""),
            mode: .date,
            date: ininitialDate ?? now,
            maximumDate: now,
            minimumDate: Calendar.current.date(byAdding: .year, value: -10, to: now)
        )

        controller.output = .init(
            close: { [weak from] in
                from?.dismiss(animated: true)
            },

            selectDate: { [weak from] date in
                completion(date)
                from?.dismiss(animated: true)
            }
        )

        from.showBottomSheet(contentViewController: controller)
    }
    
    private func openApplicationExpensesInputBottomViewController(
        from: UIViewController,
        initialText: String?,
        completion: @escaping (String) -> Void
    ) {
        let controller = CommonBottomViewController()
        
        controller.input =  .init(
            title: NSLocalizedString("dms_cost_recovery_insurance_event_expenses_amount_input_title", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_expenses_amount_input_request", comment: ""),
            initialText: initialText,
            keyboardType: .decimalPad,
            autocapitalizationType: .none,
            validationRules: [
                RequiredValidationRule(),
                LengthValidationRule(minChars: 0, maxChars: 9),
                CurrencyValidationRule(),
                IntegerPartLengthValidationRule(maxChars: 6)
            ],
            maxCharacterCount: .limited(9),
            preventInputOnLimit: true,
            hideCounter: true
        )
        
        controller.output = .init(
            completion: { [weak from] expenses in
                var expenses = expenses
                
                if let fractionPart = expenses.components(separatedBy: CharacterSet(charactersIn: ".,"))[safe: 1],
                   fractionPart.count == 1 {
                    expenses += "0"
                }
                
                completion(expenses)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
    
    private func openEmailInputBottomViewController(
        from: UIViewController,
        initialEmailText: String,
        completion: @escaping (String) -> Void
    ) {
        let controller = EmailInputBottomViewController()
        
        controller.input = .init(
            title: NSLocalizedString("dms_cost_recovery_email_input_title", comment: ""),
            placeholder: "",
            initialEmailText: initialEmailText
        )
        
        controller.output = .init(
            completion: { [weak from] email in
                completion(email)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
    
    private func createDmsCostRecoveryBankDetailsViewController() -> DmsCostRecoveryBankDetailsViewController {
        let viewController: DmsCostRecoveryBankDetailsViewController = storyboard.instantiate()
        container?.resolve(viewController)

        viewController.input = .init(
            requisites: self.requisites
        )

        viewController.output = .init(
            doneButtonTap: {
                self.navigationController?.popViewController(animated: true)
            },
            personalAccountInput: {
                self.openPersonalAccountInputBottomViewController(
                    from: viewController,
                    initialText: self.requisites.accountNumber,
                    completion: { accountNumberString in
                        self.requisites.accountNumber = accountNumberString
                        viewController.notify.accountNumberEntered(accountNumberString)
                    }
                )
            },
            showBankSearch: {
                let viewController = self.createDmsCostRecoveryBankSearchViewController()
                              
                self.createAndShowNavigationController(
                    viewController: viewController,
                    mode: .push
                )
            }
        )
        
        requisitesUpdatedSubscriptions
            .add { [weak viewController] requisites in
                if let selectedBank = requisites.bank {
                    viewController?.notify.bankSelected(selectedBank)
                }

                viewController?.notify.actionButtonEnabled(requisites.isFilled)
            }
            .disposed(by: viewController.disposeBag)
        
        return viewController
    }
    
    private func openPersonalAccountInputBottomViewController(
        from: UIViewController,
        initialText: String?,
        completion: @escaping (String) -> Void
    ) {
        let controller = InputBottomViewController()
        
        container?.resolve(controller)
        
        let input = InputBottomViewController.InputObject(
            text: initialText,
            placeholder: NSLocalizedString("dms_cost_recovery_details_recipient_bank_personal_account_request", comment: ""),
            charsLimited: .limited(20),
            keyboardType: .numberPad,
            validationRule: [
                RequiredValidationRule(),
                LengthValidationRule(countChars: 20)
            ],
            preventInputOnLimit: true
        )
        
        controller.input = .init(
            title: NSLocalizedString("dms_cost_recovery_details_recipient_bank_personal_account", comment: ""),
            infoText: nil,
            inputs: [input]
        )
        
        controller.output = .init(
            close: { [weak from] in
                from?.dismiss(animated: true)
            },
            done: { [weak from] result in
                let accountNumberString = result[input.id] ?? ""
                completion(accountNumberString)
                from?.dismiss(animated: true)
            }
        )
                        
        from.showBottomSheet(contentViewController: controller)
    }
    
    private var userCurrencyInput: String?
        
    private func createDmsCostRecoveryCurrencySelectionViewController(
        _ currencies: [DmsCostRecoveryCurrency],
        completion: @escaping (DmsCostRecoveryCurrency) -> Void
    ) -> EuroProtocolMultipleChoiceListViewController {
        let viewController = EuroProtocolMultipleChoiceListViewController()
        container?.resolve(viewController)
    
        func title(for currency: DmsCostRecoveryCurrency) -> String {
            if currency.isUserInputRequired {
                if let userInput = self.userCurrencyInput {
                    return "\(currency.title) (\(userInput))"
                } else {
                    return currency.title
                }
           } else {
               return currency.title
           }
        }
        
        func selection(for currency: DmsCostRecoveryCurrency) -> Bool {
            if currency.isUserInputRequired {
                if let userInput = self.userCurrencyInput {
                    return userInput == self.insuranceEventApplicationInfo.currency?.value
                } else { return false }
            } else {
                return currency.value == self.insuranceEventApplicationInfo.currency?.value
            }
        }
        
        let selectables = currencies.map {
            CurrencySelectable(
                id: $0.title,
                title: title(for: $0),
                isSelected: selection(for: $0),
                activateUserInput: $0.isUserInputRequired
            )
        }
                
        viewController.input = .init(
            canDeselectSingleItem: false,
            title: NSLocalizedString("dms_cost_recovery_insurance_event_currency", comment: ""),
            items: selectables,
            maxSelectionNumber: 1,
            buttonTitle: NSLocalizedString("common_done_button", comment: "")
        )
        
        viewController.output = .init(
            save: { indices in
                guard let idx = indices.first
                else { return }
                
                let currency = DmsCostRecoveryCurrency(
                    title: currencies[idx].title,
                    value: currencies[idx].isUserInputRequired ? self.userCurrencyInput ?? "" : currencies[idx].value,
                    isUserInputRequired: currencies[idx].isUserInputRequired
                )
                
                completion(currency)
                self.navigationController?.popViewController(animated: true)
            },
            userInputForSelectedItemHandler: { [weak viewController] itemIndex, completion in
                guard let viewController = viewController
                else { return }
                
                self.openApplicationCurrencyInputBottomViewController(
                    from: viewController,
                    initialText: self.userCurrencyInput,
                    completion: { currency in
                        self.userCurrencyInput = currency
                        // update text on caller
                        completion("\(currencies[itemIndex].title) (\(currency))")
                    }
                )
            }
        )
        
        return viewController
    }
    
    private var userMedicalServiceInput: String?
    
    private func createDmsCostRecoveryMedicalServicesSelectionViewController(
        _ medicalServices: [DmsCostRecoveryMedicalService],
        completion: @escaping (DmsCostRecoveryMedicalService) -> Void
    ) -> EuroProtocolMultipleChoiceListViewController {
        let viewController = EuroProtocolMultipleChoiceListViewController()
        container?.resolve(viewController)

        func title(for service: DmsCostRecoveryMedicalService) -> String {
            if service.isUserInputRequired {
                if let userInput = self.userMedicalServiceInput {
                    return "\(service.title) (\(userInput))"
                } else {
                    return service.title
                }
           } else {
               return service.title
           }
        }
        
        func selection(for service: DmsCostRecoveryMedicalService) -> Bool {
            if service.isUserInputRequired {
                if let userInput = self.userMedicalServiceInput {
                    return userInput == self.insuranceEventApplicationInfo.medicalService?.value
                } else { return false }
            } else {
                return service.value == self.insuranceEventApplicationInfo.medicalService?.value
            }
        }
        
        let selectables = medicalServices.map {
            MedicalServiceSelectable(
                id: $0.title,
                title: title(for: $0),
                isSelected: selection(for: $0),
                activateUserInput: $0.isUserInputRequired
            )
        }
                
        viewController.input = .init(
            canDeselectSingleItem: false,
            title: NSLocalizedString("dms_cost_recovery_insurance_event_application_type_input_title", comment: ""),
            items: selectables,
            maxSelectionNumber: 1,
            buttonTitle: NSLocalizedString("common_done_button", comment: "")
        )
        
        viewController.output = .init(
            save: { indices in
                guard let idx = indices.first
                else { return }
                
                let service = DmsCostRecoveryMedicalService(
                    title: medicalServices[idx].title,
                    value: medicalServices[idx].isUserInputRequired ? self.userMedicalServiceInput ?? "" : medicalServices[idx].value,
                    isUserInputRequired: medicalServices[idx].isUserInputRequired
                )
                
                completion(service)
                self.navigationController?.popViewController(animated: true)
            },
            userInputForSelectedItemHandler: { [weak viewController] itemIndex, completion in
                guard let viewController = viewController
                else { return }
                
                self.openApplicationTypeInputBottomViewController(
                    from: viewController,
                    initialText: self.userMedicalServiceInput,
                    completion: { service in
                        self.userMedicalServiceInput = service
                        
                        completion("\(medicalServices[itemIndex].title) (\(service))")
                    }
                )
            }
        )
        
        return viewController
    }
            
    private var cancellable: CancellableNetworkTaskContainer?
    
    private func createDmsCostRecoveryBankSearchViewController() -> DmsCostRecoveryBankSearchViewController {
        let viewController: DmsCostRecoveryBankSearchViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.input = .init(
            selectedBank: requisites.bank,
            popularBanks: dmsCostRecoveryResult?.popularBanks ?? [],
            searchBanks: { query, completion in
                
                self.cancellable?.cancel()
                
                self.cancellable = CancellableNetworkTaskContainer()
                let networkTask = self.dmsCostRecoveryService.searchBanks(query: query) { result in
                    switch result {
                        case .success(let banks):
                            completion(banks)
                        case .failure(let error):
                            guard !error.isCanceled
                            else { return }
                            
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
                self.cancellable?.addCancellables([ networkTask ])
            }
        )
        
        viewController.output = .init(
            doneButtonTap: {
                self.navigationController?.popViewController(animated: true)
            },
            bankSelectionUpdated: { selectedBank in
                self.requisites.bank = selectedBank
                self.requisites.accountNumber = nil
            }
        )
        
        return viewController
    }
        
    // MARK: - second step
    
    private func createDmsCostRecoveryInsuredPersonInfoViewController() -> DmsCostRecoveryInsuredPersonInfoViewController {
        let viewController: DmsCostRecoveryInsuredPersonInfoViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.input = .init(
            insuredPersons: dmsCostRecoveryResult?.insuredPersons ?? [],
            selectedInsuredPerson: selectedInsuredPerson,
            insuranceEventApplicationInfoFilled: insuranceEventApplicationInfo.isFilled,
            stepDataFilled: insuranceEventInfoFilled
        )
        
        viewController.output = .init(
            applyForm: {
                let completion = { (_ result: Result<DmsCostRecoveryApplicationResponse, AlfastrahError>) -> Void in
                    switch result {
                        case .success(let applicationResponse):
                            self.dmsCostRecoveryApplicationResponse = applicationResponse
                            viewController.notify.updateWithState(.success)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                self.applicationConfirmedSubscriptions.fire(applicationResponse)
                            }
                        case .failure:
                            viewController.notify.updateWithState(.failure)
                    }
                }
                
                guard let insuranceId = self.insuranceId
                else { return }
                
                if let applicationRequest = self.createDmsCostRecoveryApplicationRequest() {
                    viewController.notify.updateWithState(.loading)
                    if let applicationId = self.dmsCostRecoveryApplicationResponse?.applicationId {
                        self.dmsCostRecoveryService.editApplication(
                            applicationId: applicationId,
                            applicationRequest: applicationRequest,
                            completion: completion
                        )
                    } else {
                        self.dmsCostRecoveryService.createApplication(
                            insuranceId: insuranceId,
                            applicationRequest: applicationRequest,
                            completion: completion
                        )
                    }
                } else {
                    self.alertPresenter.show(alert: ErrorNotificationAlert(
                        error: nil,
                        text: NSLocalizedString("dms_cost_recovery_incorrectly_filled_data_for_application_request", comment: ""))
                    )
                }
            },
            formSentSuccessCallback: {
                self.dmsCostRecoveryFormViewController?.showNextPage()
            },
            previousStep: {
                self.dmsCostRecoveryFormViewController?.showPreviousPage()
            },
            retryToGetData: {
                self.dmsCostRecoveryFormViewController?.showNextPage()
            },
            showInsuredPersonSelection: {
                guard let insuredPersons = self.dmsCostRecoveryResult?.insuredPersons
                else { return }
                
                let viewController = self.createDmsCostRecoveryPersonSelectionViewController(insuredPersons) { [weak viewController] selectedInsuredPerson in
                    self.selectedInsuredPerson = selectedInsuredPerson
                    viewController?.notify.insuredPersonSelected(selectedInsuredPerson)
                }
                 
                self.createAndShowNavigationController(
                    viewController: viewController,
                    mode: .push
                )
            },
            showInsuranceEvent: {
                let viewController = self.createDmsCostRecoveryInsuranceEventViewController()
                
                self.createAndShowNavigationController(
                    viewController: viewController,
                    mode: .push
                )
            }
        )
        
        insuranceEventInfoFilledSubscriptions
            .add(viewController.notify.stepDataFilled)
            .disposed(by: viewController.disposeBag)
        
        insuranceEventApplicationInfoUpdatedSubscriptions
            .add{ [weak viewController] _ in
                viewController?.notify.isInsuranceEventFilled(self.insuranceEventApplicationInfo.isFilled)
            }
            .disposed(by: viewController.disposeBag)
        
        return viewController
    }
    
    enum DmsCostRecoveryApplicationError: Error {
        case error(message: String?)
    }
    
    private func createDmsCostRecoveryApplicationRequest() -> DmsCostRecoveryApplicationRequest? {
        guard let selectedInsuredPerson = selectedInsuredPerson
        else { return nil }
        
        guard let passportSeries = passport.series,
              let passportNumber = passport.number,
              let passportIssuer = passport.issuer,
              let passportIssueDate = passport.issueDate,
              let passportBirthDate = passport.birthPlace,
              let passportCitizenship = passport.citizenship
        else { return nil }
        
        guard let selectedBank = requisites.bank,
              let accountNumber = requisites.accountNumber
        else { return nil }
        
        let citizenship: DmsCostRecoveryAdditionalInfo.СitizenshipType = {
            switch self.additionalInfo.kind {
                case .nonResident:
                    return DmsCostRecoveryAdditionalInfo.СitizenshipType.nonResident
                case .rfCitizen:
                    return DmsCostRecoveryAdditionalInfo.СitizenshipType.citizen
            }
        }()
        
        guard let eventCountry = insuranceEventApplicationInfo.country,
              let eventDate = insuranceEventApplicationInfo.date,
              let eventMedicalService = insuranceEventApplicationInfo.medicalService?.value,
              let eventReason = insuranceEventApplicationInfo.reason,
              let eventExpenses = insuranceEventApplicationInfo.expensesAmount,
              let eventCurrency = insuranceEventApplicationInfo.currency?.value
        else { return nil }
        
        guard let fullname = applicantPersonalInfo.fullname,
              let birthday = applicantPersonalInfo.birthday,
              let policyNumber = applicantPersonalInfo.policyNumber,
              let phone = applicantPersonalInfo.phone,
              let email = applicantPersonalInfo.email
        else { return nil }
        
        let passport = DmsCostRecoveryPassport(
            series: passportSeries,
            number: passportNumber,
            issuer: passportIssuer,
            issueDate: passportIssueDate,
            birthPlace: passportBirthDate,
            citizenship: passportCitizenship
        )
        
        let requisites = DmsCostRecoveryRequisites(bank: selectedBank, accountNumber: accountNumber)
        
        let additionalInfo = DmsCostRecoveryAdditionalInfo(
            citizenship: citizenship,
            snils: additionalInfo.rfCitizen.snils,
            inn: additionalInfo.rfCitizen.inn,
            migrationCardNumber: additionalInfo.nonResident.migrationCardNumber,
            residentialAddress: additionalInfo.nonResident.residentialAddress
        )

        let insuranceEventApplicationInfo = DmsCostRecoveryInsuranceEventApplicationInfo(
            country: eventCountry,
            date: eventDate,
            medicalService: eventMedicalService,
            reason: eventReason,
            expensesAmount: eventExpenses.replacingOccurrences(of: ",", with: "."),
            currency: eventCurrency
        )
        
        let applicantPersonalInfo = DmsCostRecoveryApplicantPersonalInfo(
            fullname: fullname,
            birthday: birthday,
            policyNumber: policyNumber,
            serviceNumber: applicantPersonalInfo.serviceNumber,
            phone: phone,
            email: email
        )

        let request = DmsCostRecoveryApplicationRequest(
            applicantPersonalInfo: applicantPersonalInfo,
            passport: passport,
            requisites: requisites,
            additionalInfo: additionalInfo,
            insuredPersonInfo: selectedInsuredPerson,
            insuranceEventInfo: insuranceEventApplicationInfo
        )

        return request
    }
    
    private func createDmsCostRecoveryPersonSelectionViewController(
        _ insuredPersons: [DmsCostRecoveryInsuredPerson],
        completion: @escaping (DmsCostRecoveryInsuredPerson) -> Void
    ) -> EuroProtocolMultipleChoiceListViewController {
        let viewController = EuroProtocolMultipleChoiceListViewController()
        container?.resolve(viewController)
                
        let selectables = insuredPersons.map {
            PersonSelectable(
                title: $0.fullname,
                isSelected: $0 == selectedInsuredPerson ? true : false,
                activateUserInput: false
            )
        }
        
        viewController.input = .init(
            canDeselectSingleItem: false,
            title: NSLocalizedString("dms_cost_recovery_insured_person_info", comment: ""),
            items: selectables,
            maxSelectionNumber: 1,
            buttonTitle: NSLocalizedString("common_done_button", comment: "")
        )
        
        viewController.output = .init(
            save: { indices in
                guard let idx = indices.first
                else { return }
  
                self.navigationController?.popViewController(animated: true)
                
                completion(insuredPersons[idx])
            },
            userInputForSelectedItemHandler: nil
        )
        
        return viewController
    }
    
    private func createDmsCostRecoveryInsuranceEventViewController() -> DmsCostRecoveryEditableSectionsViewController {
        let viewController: DmsCostRecoveryEditableSectionsViewController = storyboard.instantiate()
        container?.resolve(viewController)
               
        let applicationDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter
        }()
        
        func items() -> [SectionsCardView.Item] {
            return [
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_insurance_event_country", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_country", comment: ""),
                    value: self.insuranceEventApplicationInfo.country,
                    icon: .rightArrow,
                    isEnabled: true,
                    tapHandler: {
                        self.openCountryInputBottomViewController(
                            from: viewController,
                            initialText: self.insuranceEventApplicationInfo.country,
                            completion: { country in
                                self.insuranceEventApplicationInfo.country = country
                            }
                        )
                    }
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_insurance_event_application_date", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_application_date", comment: ""),
                    value: self.insuranceEventApplicationInfo.date.map { applicationDateFormatter.string(from: $0) },
                    icon: .rightArrow,
                    isEnabled: true,
                    tapHandler: {
                        self.openApplicationDateInputBottomViewController(
                            from: viewController,
                            ininitialDate: self.insuranceEventApplicationInfo.date,
                            completion: { date in
                                self.insuranceEventApplicationInfo.date = date
                            }
                        )
                    }
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_insurance_event_application_type", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_application_type", comment: ""),
                    value: {
                        guard let service = self.insuranceEventApplicationInfo.medicalService
                        else { return "" }
                        
                        return service.isUserInputRequired && !service.value.isEmpty
                            ? "\(service.title) (\(service.value))"
                            : service.title
                    }(),
                    icon: .rightArrow,
                    isEnabled: true,
                    tapHandler: {
                        guard let services = self.dmsCostRecoveryResult?.medicalServices
                        else { return }
                        
                        let viewController = self.createDmsCostRecoveryMedicalServicesSelectionViewController(services) { selectedService in
                            self.insuranceEventApplicationInfo.medicalService = selectedService
                        }
                        
                        self.createAndShowNavigationController(
                            viewController: viewController,
                            mode: .push
                        )
                    }
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_insurance_event_application_reason", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_application_reason", comment: ""),
                    value: self.insuranceEventApplicationInfo.reason,
                    icon: .rightArrow,
                    isEnabled: true,
                    tapHandler: {
                        self.openApplicationReasonInputBottomViewController(
                            from: viewController,
                            initialText: self.insuranceEventApplicationInfo.reason,
                            completion: { reason in
                                self.insuranceEventApplicationInfo.reason = reason
                            }
                        )
                    }
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_insurance_event_expenses_amount", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_expenses_amount", comment: ""),
                    value: self.insuranceEventApplicationInfo.expensesAmount,
                    icon: .rightArrow,
                    isEnabled: true,
                    tapHandler: {
                        self.openApplicationExpensesInputBottomViewController(
                            from: viewController,
                            initialText: self.insuranceEventApplicationInfo.expensesAmount,
                            completion: { expensesAmount in
                                self.insuranceEventApplicationInfo.expensesAmount = expensesAmount
                            }
                        )
                    }
                ),
                SectionsCardView.Item(
                    title: NSLocalizedString("dms_cost_recovery_insurance_event_currency", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_insurance_event_currency", comment: ""),
                    value: {
                        guard let currency = self.insuranceEventApplicationInfo.currency
                        else { return "" }
                        
                        return currency.isUserInputRequired && !currency.value.isEmpty
                            ? "\(currency.title) (\(currency.value))"
                            : currency.title
                    }(),
                    icon: .rightArrow,
                    isEnabled: true,
                    tapHandler: {
                        guard let currnecies = self.dmsCostRecoveryResult?.currencies
                        else { return }
                        
                        let viewController = self.createDmsCostRecoveryCurrencySelectionViewController(currnecies) { selectedCurrency in
                            self.insuranceEventApplicationInfo.currency = selectedCurrency
                        }
                        
                        self.createAndShowNavigationController(
                            viewController: viewController,
                            mode: .push
                        )
                    }
                )
            ]
        }
        
        viewController.input = .init(
            title: NSLocalizedString("dms_cost_recovery_insurance_event", comment: ""),
            filled: self.insuranceEventApplicationInfo.isFilled,
            items: items
        )
        
        viewController.output = .init(
            actionButtonTap: {
                self.navigationController?.popViewController(animated: true)
            }
        )
        
        insuranceEventApplicationInfoUpdatedSubscriptions
            .add { [weak viewController] _ in
                viewController?.notify.updateItems(self.insuranceEventApplicationInfo.isFilled)
            }
            .disposed(by: viewController.disposeBag)

        return viewController
    }
    
    // MARK: - third step
    private func createDmsCostRecoveryApplicationPreviewViewController() -> DmsCostRecoveryApplicationPreviewViewController {
        let viewController: DmsCostRecoveryApplicationPreviewViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.output = .init(
            applicationPreview: {
                guard let path = self.dmsCostRecoveryApplicationResponse?.details.links.first?.path,
                      let applicationUrl = URL(string: path)
                else { return }
                
                WebViewer.openDocument(
                    applicationUrl,
                    from: self.navigationController ?? viewController
                )
            },
            editApplication: {
                self.dmsCostRecoveryFormViewController?.showPreviousPage()
            },
            confirmApplication: {
                self.dmsCostRecoveryFormViewController?.showNextPage()
            }
        )
        
        return viewController
    }
    
    // MARK: - fourth step
    private var initialDmsRecoveryType: DmsCostRecoveryDocumentsByType?
    private var isBlocked: Bool = false
    private var uploadError: Error?
    private var agreementConfirmed: Bool = false
    private var recoveryTypeAttachmentsFilledWithFiles: Bool = false
    private var filesSizeUpperBoundWasExceeded: Bool = false
    
    private func createDmsCostRecoveryFilesUploadViewController() -> DmsCostRecoveryFilesUploadViewController {
        let viewController: DmsCostRecoveryFilesUploadViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        if let documentInfo = dmsCostRecoveryResult?.documentsInfo {
            viewController.input = .init(
                documentsInfo: documentInfo
            )
            
            viewController.output = .init(
                sendDocuments: {
                    func updateUploadState(with description: String = "") {
                        let uploaded = self.documentsUploads.values.filter { $0.result != nil }
                        let totalUploads = self.documentsUploads.values.count
                        let format = NSLocalizedString("dms_cost_recovery_upload_files_state_description", comment: "")
                        
                        operationStatusController.notify.updateWithState(
                            .upload(String(
                                format: format,
                                "\(uploaded.count)",
                                "\(totalUploads)"),
                                description
                            )
                        )
                    }
                    
                    guard let applicationId = self.dmsCostRecoveryApplicationResponse?.applicationId
                    else { return }
                    
                    self.uploadError = nil
                    
                    let failedUploads = self.documentsUploads.values.filter { $0.result?.error != nil }
                    failedUploads.forEach { failedUpload in
                        self.documentsUploads.removeValue(forKey: failedUpload.attachment.id)
                        self.uploadDocument(failedUpload.attachment, uploadName: failedUpload.uploadName)
                    }
                    
                    let operationStatusController = self.createDmsOperationStatusViewController()
                    
                    self.setInitialState = { [weak self] in
                        guard let self = self
                        else { return }
                        
                        let pendingUploads = self.documentsUploads.values.filter { $0.result == nil }
                        if pendingUploads.isEmpty {
                            self.onAllUploadsCompleted?()
                        } else {
                            updateUploadState()
                        }
                    }
                    
                    self.fileWasUpload = { [weak self] result in
                        guard let self = self
                        else { return }
                                                    
                        switch result {
                            case .success:
                                updateUploadState()
                            case .failure(let error):
                                self.uploadError = error
                        }
                    }
                                        
                    self.onAllUploadsCompleted = { [weak self, weak operationStatusController] in
                            guard let self = self,
                                  let operationStatusController = operationStatusController
                            else { return }
                        
                            if self.uploadError != nil {
                                operationStatusController.dismiss(animated: true)
                            }
                            updateUploadState(
                                with: NSLocalizedString("dms_cost_recovery_operation_status_sending_application", comment: "")
                            )
                            self.dmsCostRecoveryService.submitApplication(
                                applicationId: String(applicationId),
                                documentsIds: self.documentsUploads.values.compactMap {
                                    if let documentId = $0.result?.value,
                                       let documentId = documentId {
                                        return String(documentId)
                                    }
                                    return nil
                                }
                            ) { result in
                                switch result {
                                    case .success(let response):
                                        if response.isApplicationAccepted {
                                            operationStatusController.notify.updateWithState(
                                                .success(response.title, response.description)
                                            )
                                        } else {
                                            operationStatusController.notify.updateWithState(
                                                .failure(response.title, response.description)
                                            )
                                        }
                                    case .failure:
                                        operationStatusController.notify.updateWithState(.failure(
                                            NSLocalizedString("dms_cost_recovery_operation_status_server_error_title", comment: ""),
                                            NSLocalizedString("dms_cost_recovery_application_error_description", comment: "")
                                        ))
                                }
                            }
                    }
                    
                    self.createAndShowNavigationController(
                        viewController: operationStatusController,
                        mode: .modal
                    )
                },
                selectRecoveryType: { completion in
                    self.openRecoveryTypeSelectionInputBottomViewController(
                        from: viewController,
                        initialRecoveryType: self.initialDmsRecoveryType,
                        documentInfo.documentsByType,
                        completion: { selectedRecoveryType in
                            self.initialDmsRecoveryType = selectedRecoveryType
                            completion(selectedRecoveryType)
                        }
                    )
                },
                showDocument: { url in
                    WebViewer.openDocument(url, from: viewController)
                },
                selectFilesForUpload: { [weak viewController] documentsList in
                    guard let viewController = viewController
                    else { return }
                    
                    let controller = self.createDmsCostRecoverySelectFilesViewController(documentsList) {
                        let totalSize = self.calculateAttachmentsTotalSize()
                        
                        self.filesSizeUpperBoundWasExceeded = totalSize > 20 * 1024 * 1024 // 20Mb
                        
                        viewController.notify.uploadStatusChanged(totalSize)

                        viewController.notify.documentAttachmentsUpdated(documentsList, self.getUploads(for: documentsList).map { $0.attachment })
                        
                        self.recoveryTypeAttachmentsFilledWithFiles = self.filesHaveAttachments(documentsList: documentsList)
                        
                        viewController.notify.isSendButtonEnabled(self.applicationCanBeSubmit())
                    }
                    
                    self.createAndShowNavigationController(
                        viewController: controller,
                        mode: .push
                    )
                },
                updateAgreementState: { [weak viewController] checked in
                    
                    self.agreementConfirmed = checked
                    
                    viewController?.notify.isSendButtonEnabled(self.applicationCanBeSubmit())
                }
            )
        }
        
        applicationConfirmedSubscriptions
            .add { [weak viewController] applicationResponse in
                viewController?.notify.applicationConfirmed(applicationResponse)
            }
            .disposed(by: viewController.disposeBag)
        
        return viewController
    }
    
    private func applicationCanBeSubmit() -> Bool {
        return self.agreementConfirmed && self.recoveryTypeAttachmentsFilledWithFiles && !self.filesSizeUpperBoundWasExceeded
    }
    
    private func calculateAttachmentsTotalSize() -> Int64 {
        return self.documentsUploads.reduce(Int64(0)){
            $0 + (attachmentService.size(from: $1.value.attachment.url) ?? 0)
        }
    }
    
    private func createDmsCostRecoverySelectFilesViewController(
        _ documentsList: DmsCostRecoveryDocumentsList,
        completion: @escaping () -> Void
    ) -> DmsCostRecoverySelectFilesController {
        let viewController: DmsCostRecoverySelectFilesController = storyboard.instantiate()
        container?.resolve(viewController)

        viewController.input = .init(
            documentsList: documentsList,
            getDocumentUploads: {
                return self.getUploads(for: documentsList).map {
                    DmsCostRecoverySelectFilesController.Upload(
                        uploadName: $0.uploadName,
                        attachment: $0.attachment
                    )
                }
            },
            nextButtonEnabled: {
                return self.filesHaveAttachments(documentsList: documentsList)
            }
        )
        
        viewController.output = .init(
            addFile: { [weak viewController] file in
                guard let viewController = viewController
                else { return }
                
                let step = BaseDocumentStep(
                    title: file.title,
                    minDocuments: 0,
                    maxDocuments: file.isMultiselectAllowed ? 200 : 1,
                    attachments: {
                        return self.getUploads(for: documentsList).compactMap { $0.uploadName == file.uploadName ? $0.attachment : nil }
                    }()
                )
                
                self.openFilesUploadInputBottomViewController(
                    from: viewController,
                    step,
                    for: file,
                    completion: { [weak viewController] attachments in
                        viewController?.notify.update(file, attachments)
                        
                        let enabled = self.filesHaveAttachments(documentsList: documentsList)
                        viewController?.notify.isNextButtonEnabled(enabled)
                        completion()
                    }
                )
            },
            nextButtonTap: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
        
        return viewController
    }
    
    private func filesHaveAttachments(documentsList: DmsCostRecoveryDocumentsList) -> Bool {
        for file in documentsList.documents {
            if !documentsUploads.contains(where: { $0.value.uploadName == file.uploadName }) {
                return false
            }
        }
        return true
    }
    
    private func getUploads(for documentsList: DmsCostRecoveryDocumentsList) -> [DocumentUpload] {
        var uploads: [DocumentUpload] = []

        for file in documentsList.documents {
            let items = documentsUploads.values.compactMap { $0.uploadName == file.uploadName ? $0 : nil }

            uploads.append(contentsOf: items)
        }
        
        return uploads
    }
    
    private func recoveryTypeHasDocuments(documentsByType: DmsCostRecoveryDocumentsByType) -> Bool {
        for documentsList in documentsByType.documentsLists {
            if !filesHaveAttachments(documentsList: documentsList) {
                return false
            }
        }
        
        return true
    }

    private struct DocumentUpload {
        let id: DmsCostRecoveryService.DocumentUploadId
        let attachment: Attachment
        let uploadName: String
        
        var result: DmsCostRecoveryService.DocumentUploadResult?
    }
    
    private typealias AttachmentId = String
    private var documentsUploads: [AttachmentId: DocumentUpload] = [:]
    
    private var onAllUploadsCompleted: (() -> Void)?
    private var fileWasUpload: ((DmsCostRecoveryService.DocumentUploadResult) -> Void)?
    private var setInitialState: (() -> Void)?
        
    private func openFilesUploadInputBottomViewController(
        from: UIViewController,
        _ step: BaseDocumentStep,
        for file: DmsCostRecoveryDocument,
        completion: @escaping ([Attachment]) -> Void
    ) {
        let viewController: DocumentInputBottomViewController = .init()
        container?.resolve(viewController)
        
        let actionSheetViewController = ActionSheetViewController(with: viewController)
                
        viewController.input = .init(
            title: step.title,
            description: NSLocalizedString("disagreement_with_services_documents_sheet_hint", comment: ""),
            doneButtonTitle: NSLocalizedString("dms_cost_recovery_documents_sheet_done", comment: ""),
            step: step,
            showTotalFilesSize: true
        )
        
        viewController.output = .init(
            close: { [weak viewController] in
                viewController?.dismiss(animated: true)
            },
            done: { [weak viewController] in
                viewController?.dismiss(animated: true)
            },
            delete: { attachments in
                let ids = attachments.map { $0.id }
                step.attachments.removeAll { ids.contains($0.id) }
                self.photosUpdatedSubscriptions.fire(())
                
                attachments.forEach { attachment in
                    self.attachmentService.delete(attachment: attachment)
                    
                    if let upload = self.documentsUploads.removeValue(forKey: attachment.id) {
                        self.dmsCostRecoveryService.cancelDocumentUpload(uploadId: upload.id)
                    }
                }
                completion(step.attachments)
            },
            pickFile: { [weak actionSheetViewController] in
                guard let actionSheetViewController = actionSheetViewController
                else { return }
                
                self.pickFiles(
                    to: step,
                    for: file,
                    from: actionSheetViewController
                ) { attachments in
                    completion(attachments)
                }
            },
            showPhoto: { [weak actionSheetViewController] showPhotoController, animated, completion in
                actionSheetViewController?.present(
                    showPhotoController,
                    animated: animated,
                    completion: completion
                )
            },
            openDocument: { [weak viewController] attachment in
                guard let viewController = viewController
                else { return }
                
                LocalDocumentViewer.open(
                    attachment.url,
                    from: viewController
                )
            }
        )
        
        photosUpdatedSubscriptions
            .add(viewController.notify.filesUpdated)
            .disposed(by: viewController.disposeBag)
        
        from.present(
            actionSheetViewController,
            animated: true
        )
    }
        
    private func pickFiles(
        to documentsStep: BaseDocumentStep,
        for file: DmsCostRecoveryDocument,
        from viewController: UIViewController,
        completion: (([Attachment]) -> Void)? = nil
    ) {
        documentSelectionBehavior.pickDocuments(
            viewController,
            attachmentService: attachmentService,
            sources: [.library, .icloud, .camera],
            maxDocuments: documentsStep.maxDocuments - documentsStep.attachments.count,
            callback: { attachments in
                                
                documentsStep.attachments.append(contentsOf: attachments)
                self.photosUpdatedSubscriptions.fire(())
                
                attachments.forEach { attachment in
                    self.uploadDocument(attachment, uploadName: file.uploadName)
                }
                
                completion?(attachments)
            }
        )
    }
    
    private func uploadDocument(_ attachment: Attachment, uploadName: String) {
        guard let insuranceId = self.insuranceId,
              let applicationId = self.dmsCostRecoveryApplicationResponse?.applicationId
        else { return }

        let uploadId = dmsCostRecoveryService.uploadDocument(
            insuranceId: insuranceId,
            applicationId: applicationId,
            uploadName: uploadName,
            attachment: attachment,
            completion: { result in
                self.documentsUploads[attachment.id]?.result = result

                let pendingUploads = self.documentsUploads.values.filter { $0.result == nil }
                
                if pendingUploads.isEmpty {
                    self.onAllUploadsCompleted?()
                    self.isBlocked = false
                    return
                }
                
                if !self.isBlocked {
                    self.isBlocked = true
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.fileWasUpload?(result)
                        self.isBlocked = false
                    }
                }
            }
        )

        if let uploadId = uploadId {
            documentsUploads[attachment.id] = .init(
                id: uploadId,
                attachment: attachment,
                uploadName: uploadName
            )
        }
    }
    
    private func openRecoveryTypeSelectionInputBottomViewController(
        from: UIViewController,
        initialRecoveryType: DmsCostRecoveryDocumentsByType?,
        _ types: [DmsCostRecoveryDocumentsByType],
        completion: @escaping (DmsCostRecoveryDocumentsByType) -> Void
    ) {
        let viewController: MultipleValuePickerBottomViewController = .init()
        container?.resolve(viewController)
        
        let selectables = types.map {
            RecoveryTypeSelectable(
                id: $0.title,
                title: $0.title,
                isSelected: $0 == initialRecoveryType ? true : false,
                activateUserInput: false
            )
        }

        viewController.input = .init(
            title: NSLocalizedString("dms_cost_recovery_upload_recovery_type_title", comment: ""),
            dataSource: selectables,
            isMultiSelectAllowed: false
        )

        viewController.output = .init(
            close: { [weak from] in
                from?.dismiss(animated: true)
            },
            done: { [weak from] selectedTypes in
                from?.dismiss(animated: true)
                
                if let selectedRecoveryType = types.first(where: { $0.title == selectedTypes.first?.title }) {
                    completion(selectedRecoveryType)
                }
            }
        )
        from.showBottomSheet(contentViewController: viewController)
    }
    
    private func createDmsCostRecoveryPassportDataViewController() -> DmsCostRecoveryEditableSectionsViewController {
        let viewController: DmsCostRecoveryEditableSectionsViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        func item(
            title: String,
            placeholder: String,
            initialText: @escaping @autoclosure () -> String?,
            charsLimit: Int,
            autocapitalizationType: UITextAutocapitalizationType = .none,
            completion: @escaping (String) -> Void
        ) -> SectionsCardView.Item {
            return item(
                title: title,
                value: initialText(),
                tapHandler: { [weak viewController] in
                    guard let viewController = viewController
                    else { return }
                    
                    self.openPassportInputBottomViewController(
                        from: viewController,
                        title: title,
                        placeholder: placeholder,
                        initialText: initialText(),
                        charsLimit: charsLimit,
                        autocapitalizationType: autocapitalizationType,
                        completion: completion
                    )
                }
            )
        }
        
        func item(
            title: String,
            value: String?,
            tapHandler: @escaping () -> Void
        ) -> SectionsCardView.Item {
            return .init(
                title: title,
                placeholder: title,
                value: value,
                icon: .rightArrow,
                isEnabled: true,
                tapHandler: tapHandler
            )
        }
        
        func items() -> [SectionsCardView.Item] {
            return [
                item(
                    title: NSLocalizedString("dms_cost_recovery_passport_series_title", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_passport_series_prompt", comment: ""),
                    initialText: self.passport.series,
                    charsLimit: 9,
                    completion: { series in
                        self.passport.series = series
                    }
                ),
                item(
                    title: NSLocalizedString("dms_cost_recovery_passport_number_title", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_passport_number_prompt", comment: ""),
                    initialText: self.passport.number,
                    charsLimit: 16,
                    completion: { number in
                        self.passport.number = number
                    }
                ),
                item(
                    title: NSLocalizedString("dms_cost_recovery_passport_issuer_title", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_passport_issuer_prompt", comment: ""),
                    initialText: self.passport.issuer,
                    charsLimit: 250,
                    autocapitalizationType: .sentences,
                    completion: { issuer in
                        self.passport.issuer = issuer
                    }
                ),
                {
                    let issueDateFormatter: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd.MM.yyyy"
                        return formatter
                    }()
                    
                    let title = NSLocalizedString("dms_cost_recovery_passport_issue_date_title", comment: "")
                    return item(
                        title: title,
                        value: passport.issueDate.map { issueDateFormatter.string(from: $0) },
                        tapHandler: { [weak viewController] in
                            guard let viewController = viewController
                            else { return }
                            
                            self.openPassportIssueDateInputBottomViewController(
                                from: viewController,
                                title: title,
                                initialDate: self.passport.issueDate,
                                completion: { issueDate in
                                    self.passport.issueDate = issueDate
                                }
                            )
                        }
                    )
                }(),
                item(
                    title: NSLocalizedString("dms_cost_recovery_passport_birth_place_title", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_passport_birth_place_prompt", comment: ""),
                    initialText: self.passport.birthPlace,
                    charsLimit: 250,
                    autocapitalizationType: .sentences,
                    completion: { birthPlace in
                        self.passport.birthPlace = birthPlace
                    }
                ),
                item(
                    title: NSLocalizedString("dms_cost_recovery_passport_citizenship_title", comment: ""),
                    placeholder: NSLocalizedString("dms_cost_recovery_passport_citizenship_prompt", comment: ""),
                    initialText: self.passport.citizenship,
                    charsLimit: 64,
                    autocapitalizationType: .sentences,
                    completion: { citizenship in
                        self.passport.citizenship = citizenship
                    }
                )
            ]
        }
        
        viewController.input = .init(
            title: NSLocalizedString("dms_cost_recovery_passport_data", comment: ""),
            filled: passport.isFilled,
            items: items
        )
        
        viewController.output = .init(
            actionButtonTap: {
                self.navigationController?.popViewController(animated: true)
            }
        )
        
        passportUpdatedSubscriptions
            .add { [weak viewController] _ in
                viewController?.notify.updateItems(self.passport.isFilled)
            }
            .disposed(by: viewController.disposeBag)
        
        return viewController
    }
        
    private func createDmsOperationStatusViewController() -> DmsCostRecoveryOperationStatusViewController {
        let viewController = DmsCostRecoveryOperationStatusViewController()
        
        viewController.input = .init(
            setInitialState: {
                self.setInitialState?()
            }
        )
        
        viewController.output = .init(
            goToMainScreen: {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            },
            goToChat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            flowCompleted: {
                self.navigationController?.presentingViewController?.dismiss(animated: true)
            }
        )
        return viewController
    }
    
    private func openPassportInputBottomViewController(
        from: UIViewController,
        title: String,
        placeholder: String,
        initialText: String?,
        charsLimit: Int,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        completion: @escaping (String) -> Void
    ) {
        let controller = InputBottomViewController()
        container?.resolve(controller)
        
        let input = InputBottomViewController.InputObject(
            text: initialText,
            placeholder: placeholder,
            charsLimited: .limited(charsLimit),
            keyboardType: .default,
            autocapitalizationType: autocapitalizationType,
            validationRule: [
                RequiredValidationRule(),
                LengthValidationRule(maxChars: charsLimit)
            ],
            preventInputOnLimit: true
        )
        
        controller.input = .init(
            title: title,
            infoText: nil,
            inputs: [input]
        )
        
        controller.output = .init(
            close: { [weak from] in
                from?.dismiss(animated: true)
            },
            done: { [weak from] result in
                let series = result[input.id] ?? ""
                completion(series)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
    
    private func openPassportIssueDateInputBottomViewController(
        from: UIViewController,
        title: String,
        initialDate: Date?,
        completion: @escaping (Date) -> Void
    ) {
        let controller = DateInputBottomViewController()
        container?.resolve(controller)
        
        let today = Date()
        controller.input = .init(
            title: title,
            mode: .date,
            date: initialDate ?? today,
            maximumDate: today,
            minimumDate: nil
        )
        
        controller.output = .init(
            close: { [weak from] in
                from?.dismiss(animated: true)
            },
            selectDate: { [weak from] date in
                completion(date)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
    
    private func createDmsCostRecoveryAdditionalInfoViewController() -> DmsCostRecoveryAdditionalInfoViewController {
        let viewController: DmsCostRecoveryAdditionalInfoViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.input = .init(
            .init(
                additionalInfo: additionalInfo
            )
        )
        
        viewController.output = .init(
            kindChanged: { kind in
                self.additionalInfo.kind = kind
            },
            rfCitizenInfoChanged: { rfCitizen in
                self.additionalInfo.rfCitizen = rfCitizen
            },
            nonResidentInfoChanged: { nonResident in
                self.additionalInfo.nonResident = nonResident
            },
            doneButtonTap: {
                self.navigationController?.popViewController(animated: true)
            }
        )
        
        additionalInfoUpdatedSubscriptions
            .add { [weak viewController] additionalInfo in
                viewController?.notify.additionalInfoFilled(self.additionalInfo.isFilled)
            }
            .disposed(by: viewController.disposeBag)
        
        return viewController
    }
}
