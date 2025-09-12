//
//  ClinicOfflineAppointmentViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import RealmSwift

// swiftlint:disable file_length
class ClinicOfflineAppointmentViewController: ViewController, UITextFieldDelegate {
    enum Kind {
        case confirmAppointment(OfflineAppointment)
        case viewAppointment(OfflineAppointment)

        var appointment: OfflineAppointment {
            switch self {
                case .confirmAppointment(let appointment):
                    return appointment
                case .viewAppointment(let appointment):
                    return appointment
            }
        }

        mutating func updateAppointment(_ appointment: OfflineAppointment) {
            switch self {
                case .confirmAppointment:
                    self = .confirmAppointment(appointment)
                case .viewAppointment:
                    self = .viewAppointment(appointment)
            }
        }
    }

    struct Input {
        let settings: OfflineAppointmentSettings
        let clinic: Clinic
        let userPhone: Phone?
        var insurance: Insurance
    }

    struct Output {
        var createAppointment: (ExportData) -> Void
        let selectAppointmentDate: (
            _ dateRange: DateRange?,
            _ completion: @escaping (Date) -> Void
        ) -> Void
        var phoneTap: (Phone) -> Void
        let pickDoctor: (
            _ selected: ClinicSpeciality?,
            _ completion: @escaping (ClinicSpeciality, String?) -> Void
        ) -> Void
    }

    struct Notify {
        var changed: () -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] in
            guard let `self` = self, self.isViewLoaded else { return }

            self.update()
        }
    )

    struct ExportData {
        let speciality: ClinicSpeciality
        let userInputForClinicSpeciality: String?
        let reason: String
        let userPhone: Phone
        let dates: [OfflineAppointmentDate]
        let disclaimerAnswer: String?
    }

    private struct Data {
        var selectedDoctor: ClinicSpeciality?
        var reasonText: String?
        var userPhone: Phone?
        var disclaimerAnswer: String?
        var userInputForClinicSpeciality: String?

        func exportData(dateViews: [ConvenientDateAndTimeView]) -> ExportData? {
            guard
                let specialist = selectedDoctor,
                let reason = reasonText,
                let userPhone = userPhone
            else {
                return nil
            }

            let dates = dateViews.map { element -> OfflineAppointmentDate? in
                guard let date = element.date, let (startHrs, endHrs) = element.time else {
                    return nil
                }

                return OfflineAppointmentDate(date: date, startHours: startHrs, endHours: endHrs)
            }

            guard !dates.contains(where: { $0 == nil }) else { return nil }

            let filteredDates = dates.compactMap { $0 }

            return ExportData(
                speciality: specialist,
                userInputForClinicSpeciality: userInputForClinicSpeciality,
                reason: reason,
                userPhone: userPhone,
                dates: filteredDates,
                disclaimerAnswer: disclaimerAnswer
            )
        }

        static var empty: Data = Data()
    }

    private var data: Data = .empty

    // MARK: - UI

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var createAppointmentButton: RoundEdgeButton!
    @IBOutlet private var scrollView: UIScrollView!

    // Date section

    private lazy var dateStackView: UIStackView = {
        let dateStackView = UIStackView()
        dateStackView.accessibilityIdentifier = #function
        dateStackView.spacing = 15
        dateStackView.axis = .vertical
        dateStackView.isLayoutMarginsRelativeArrangement = true
        dateStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        return dateStackView
    }()

    private lazy var innerDateStackView: UIStackView = {
        let innerDataStackView = UIStackView()
        innerDataStackView.accessibilityIdentifier = #function
        innerDataStackView.spacing = 12
        innerDataStackView.axis = .vertical
        innerDataStackView.alignment = .fill
        innerDataStackView.distribution = .fill
        return innerDataStackView
    }()

    private lazy var addOneMoreDateCardButton: UIView = {
        let addOneMoreDateCardButton = CardHorizontalButton(frame: .zero)
        addOneMoreDateCardButton.set(
            title: NSLocalizedString("clinic_appointment_add_one_more_date_card_text", comment: ""),
            icon: UIImage(named: "icon_calendar_add")
        )
        addOneMoreDateCardButton.tapHandler = { [weak self] in self?.addConvenientDateSection() }
        return CardView(contentView: addOneMoreDateCardButton)
    }()

    private lazy var contactPhoneValueCard: SmallValueCardView = {
        let card = SmallValueCardView()
        card.set(
            title: NSLocalizedString("clinic_appointment_user_phone", comment: ""),
            placeholder: NSLocalizedString("clinic_appointment_user_phone", comment: ""),
            value: input.userPhone?.humanReadable,
            error: nil, icon: .rightArrow,
            showSeparator: false
        )
        card.tapHandler = { [unowned self, card] in
            self.openPhoneInput {
                self.data.userPhone = $0
                card.update(value: $0.humanReadable)
                self.updateCreateButtonEnabledState()
            }
        }
        return card
    }()

    private lazy var doctorValueCard: SmallValueCardView = {
        let doctorCard = SmallValueCardView()
        doctorCard.set(
            title: NSLocalizedString("clinic_appointment_specialist_caption", comment: ""),
            placeholder: NSLocalizedString("clinic_appointment_specialist", comment: ""),
            value: data.selectedDoctor?.title,
            error: nil,
            icon: .rightArrow,
            showSeparator: false
        )
        doctorCard.isEnabled = true
        doctorCard.tapHandler = { [unowned self, doctorCard] in
            self.output.pickDoctor(self.data.selectedDoctor) { doctor, userInputSpecialityText in
                self.data.selectedDoctor = doctor
                self.data.userInputForClinicSpeciality = userInputSpecialityText
                
                var doctorTitle = doctor.title
                if let userInputSpecialityText = userInputSpecialityText {
                    doctorTitle += " (" + userInputSpecialityText + ")"
                }
                
                doctorCard.update(value: doctorTitle)
                self.updateCreateButtonEnabledState()
            }
        }
        return doctorCard
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        data.userPhone = input.userPhone
        commonSetup()
        update()
    }

    // MARK: - Setup UI

    private func commonSetup() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("clinic_appointment_title", comment: "")

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        stackView.spacing = 24
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 18, bottom: 9, right: 18)

        createAppointmentButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        createAppointmentButton.setTitle(
            NSLocalizedString("clinic_confirm_appointment", comment: ""),
            for: .normal
        )

        addZeroView()
    }

    private func update() {
        updateInfo()
        hideZeroView()
    }

    private func updateInfo() {
        stackView.subviews.forEach { $0.removeFromSuperview() }

        addCommonInfoSection()
        addRequestForFilling()
        addAppointmentDateSection()
        addContactsSection()
        addDoctorSection()
        addReasonSection()

        if input.settings.disclaimer != nil {
            addDisclaimerSection()
        }

        createAppointmentButton.isHidden = false
        updateCreateButtonEnabledState()
    }

    private func updateCreateButtonEnabledState() {
        let dateViews = innerDateStackView.arrangedSubviews.compactMap { $0 as? ConvenientDateAndTimeView }
        guard data.exportData(dateViews: dateViews) != nil else {
            createAppointmentButton.isEnabled = false
            return
        }

        if input.settings.disclaimer != nil, data.disclaimerAnswer == nil {
            createAppointmentButton.isEnabled = false
            return
        }

        createAppointmentButton.isEnabled = true
    }

    private func addCommonInfoSection() {
        let commonInfoStack = UIStackView()
        commonInfoStack.axis = .vertical
        commonInfoStack.alignment = .fill
        commonInfoStack.distribution = .fill
        commonInfoStack.accessibilityIdentifier = "commonInfoStack"

        let termCard = SmallValueCardView(frame: .zero)
        termCard.set(
            title: NSLocalizedString("clinic_appointment_term_of_validity_title", comment: ""),
            placeholder: "",
            value: AppLocale.shortDateString(input.insurance.endDate),
            error: nil,
            icon: .center(nil),
            showSeparator: true
        )

        commonInfoStack.addArrangedSubview(termCard)

        let nameCard = SmallValueCardView()
        nameCard.set(
            title: NSLocalizedString("clinic_appointment_insured_full_name_title", comment: ""),
            placeholder: "",
            value: input.insurance.insuredObjectTitle,
            error: nil,
            icon: .center(nil),
            showSeparator: true
        )
        commonInfoStack.addArrangedSubview(nameCard)

        let clinicNameCard = SmallValueCardView()
        clinicNameCard.set(
            title: NSLocalizedString("clinic_appointment_clinic_name_title", comment: ""),
            placeholder: "",
            value: input.clinic.title,
            error: nil,
            icon: .center(nil),
            showSeparator: true
        )
        commonInfoStack.addArrangedSubview(clinicNameCard)

        let clinicAddressCard = SmallValueCardView()
        clinicAddressCard.set(
            title: NSLocalizedString("clinic_appointment_clinic_address_title", comment: ""),
            placeholder: "",
            value: input.clinic.address,
            error: nil,
            icon: .center(nil)
        )
        commonInfoStack.addArrangedSubview(clinicAddressCard)

        stackView.addArrangedSubview(CardView(contentView: commonInfoStack))
    }

    private func addRequestForFilling() {
        let requestForFillingLabel = UILabel()
        requestForFillingLabel <~ Style.Label.secondaryText
        requestForFillingLabel.numberOfLines = 0
        requestForFillingLabel.text = NSLocalizedString("clinic_appointment_request_for_filling", comment: "")
        requestForFillingLabel.accessibilityIdentifier = "requestForFillingLabel"
        stackView.addArrangedSubview(requestForFillingLabel)
    }

    private func addAppointmentDateSection() {
        dateStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        innerDateStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("clinic_appointment_data_title", comment: "")
        dateStackView.addArrangedSubview(titleLabel)

        addConvenientDateSection()
        dateStackView.addArrangedSubview(innerDateStackView)

        dateStackView.addArrangedSubview(addOneMoreDateCardButton)

        let addDateInfoLabel = UILabel()
        addDateInfoLabel <~ Style.Label.secondaryText
        addDateInfoLabel.numberOfLines = 0
        addDateInfoLabel.text = NSLocalizedString("clinic_appointment_add_one_more_date_info_text", comment: "")
        dateStackView.addArrangedSubview(addDateInfoLabel)

        stackView.addArrangedSubview(dateStackView)
    }

    private func addDoctorSection() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15

        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("clinic_appointment_specialist_caption", comment: "")

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(CardView(contentView: doctorValueCard))
        stackView.addArrangedSubview(stack)
    }

    private func addReasonSection() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15

        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("clinic_appointment_reason", comment: "")
        stack.addArrangedSubview(titleLabel)

        let reasonCard = SmallValueCardView()
        reasonCard.set(
            title: NSLocalizedString("clinic_appointment_reason_card_title", comment: ""),
            placeholder: NSLocalizedString("clinic_appointment_reason_card_title", comment: ""),
            value: nil,
            error: nil,
            icon: .rightArrow,
            showSeparator: false
        )
        reasonCard.tapHandler = { [unowned self, reasonCard] in
            self.openReasonTextInput(initialText: self.data.reasonText) { text in
                self.data.reasonText = text
                reasonCard.update(value: text)
                self.updateCreateButtonEnabledState()
            }
        }
        stack.addArrangedSubview(CardView(contentView: reasonCard))

        stackView.addArrangedSubview(stack)
    }

    private func addContactsSection() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15

        let titleLabel = UILabel()
        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("clinic_appointment_user_contacts", comment: "")
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(CardView(contentView: contactPhoneValueCard))

        stackView.addArrangedSubview(stack)
    }

    // MARK: Actions

    @IBAction func createAppointmentTap(_ sender: UIButton) {
        view.endEditing(false)
        let dateViews = innerDateStackView.arrangedSubviews.compactMap { $0 as? ConvenientDateAndTimeView }
        guard let exportData = data.exportData(dateViews: dateViews) else { return }

        output.createAppointment(exportData)
    }

    private func addConvenientDateSection() {
        let dataCardsStack = ConvenientDateAndTimeView()
        dataCardsStack.dateCatcher = { [unowned self] completion in
            let dateRange: DateRange?
            if let date = dataCardsStack.date {
                dateRange = DateRange(startDate: date, finishDate: date)
            } else {
                dateRange = nil
            }
            self.output.selectAppointmentDate(dateRange) {
                completion($0)
                self.updateCreateButtonEnabledState()
            }
        }
        dataCardsStack.timeCatcher = { [unowned self] completion in
            self.openTimePicker(with: dataCardsStack.time) {
                completion($0)
                self.updateCreateButtonEnabledState()
            }
        }

        func updateDateStack() {
            addOneMoreDateCardButton.isHidden = innerDateStackView.subviews.count >= 3
            innerDateStackView.subviews.forEach {
                ($0 as? ConvenientDateAndTimeView)?.setButtonHiddenState(innerDateStackView.subviews.count == 1)
            }
            updateCreateButtonEnabledState()
        }

        dataCardsStack.deleteHandler = { [weak dataCardsStack] in
            dataCardsStack?.removeFromSuperview()
            updateDateStack()
        }

        innerDateStackView.addArrangedSubview(dataCardsStack)
        updateDateStack()
    }

    private func addDisclaimerSection() {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 9

        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 9
		let icon = UIImageView(image: .Icons.info.tintedImage(withColor: .Icons.iconAccent).resized(newWidth: 22))
		icon.contentMode = .center
        NSLayoutConstraint.fixWidth(view: icon, constant: 24)
        NSLayoutConstraint.fixHeight(view: icon, constant: 24)
        let label = UILabel()
        label <~ Style.Label.primaryHeadline3
        label.text = NSLocalizedString("clinic_appointment_disclaimer_title", comment: "")
        horizontalStack.addArrangedSubview(icon)
        horizontalStack.addArrangedSubview(label)

        let disclaimerLabel = UILabel()
        disclaimerLabel <~ Style.Label.primaryText
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.text = input.settings.disclaimer

        let answerCard = SmallValueCardView()
        answerCard.set(
            title: "",
            placeholder: NSLocalizedString("clinic_appointment_disclaimer_placeholder", comment: ""),
            value: nil,
            error: nil,
            icon: .rightArrow
        )
        answerCard.tapHandler = { [unowned self, answerCard] in
            self.openAnswerTextInput { text in
                self.data.disclaimerAnswer = text
                answerCard.set(
                    title: NSLocalizedString("clinic_appointment_disclaimer_placeholder", comment: ""),
                    placeholder: NSLocalizedString("clinic_appointment_disclaimer_placeholder", comment: ""),
                    value: text, error: nil
                )
                self.updateCreateButtonEnabledState()
            }
        }

        verticalStack.addArrangedSubview(horizontalStack)
        verticalStack.addArrangedSubview(disclaimerLabel)
        verticalStack.setCustomSpacing(15, after: disclaimerLabel)
        verticalStack.addArrangedSubview(CardView(contentView: answerCard))

        stackView.addArrangedSubview(verticalStack)
    }

    private func openTimePicker(with time: (Int, Int)?, _ completion: @escaping ((Int, Int)) -> Void) {
        let controller: TimeRangeInputBottomViewController = .init()
        container?.resolve(controller)
        let startTimeString = input.settings.intervalStartTime
        let startHourString = startTimeString[startTimeString.startIndex..<startTimeString.startIndex(offsetBy: 2)]
        let endTimeString = input.settings.intervalEndTime
        let endHourString = endTimeString[endTimeString.startIndex..<endTimeString.startIndex(offsetBy: 2)]
        let startHour = Int(startHourString) ?? 8
        let endHour = Int(endHourString) ?? 20
        controller.input = .init(
            title: NSLocalizedString("clinic_appointment_convenient_time_bottom_sheet_text", comment: ""),
            minHour: startHour,
            maxHour: endHour,
            defaultStartHour: time?.0 ?? startHour,
            defaultEndHour: time?.1 ?? endHour
        )

        controller.output = .init(
            close: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            },
            selectTime: { [weak self] pair in
                completion(pair)
                self?.dismiss(animated: true, completion: nil)
            }
        )

        showBottomSheet(contentViewController: controller, dragEnabled: true, dismissCompletion: nil)
    }

    private func openPhoneInput(completion: @escaping (Phone) -> Void) {
        let controller = PhoneInputBottomViewController()
        container?.resolve(controller)
        let phoneTitle = NSLocalizedString("clinic_appointment_user_phone", comment: "")
        controller.input = .init(title: phoneTitle, placeholder: phoneTitle, initialPhoneText: data.userPhone?.humanReadable)
        controller.output = .init(completion: { [weak self] plain, humanReadable in
            let phone = Phone(plain: plain, humanReadable: humanReadable)
            completion(phone)
            self?.dismiss(animated: true, completion: nil)
        })

        showBottomSheet(contentViewController: controller)
    }

    private func openReasonTextInput(initialText: String?, completion: @escaping (String) -> Void) {
        let controller = TextAreaInputBottomViewController()
        container?.resolve(controller)

        controller.input = .init(
            title: NSLocalizedString("clinic_appointment_reason", comment: ""),
            description: nil,
            textInputTitle: nil,
            textInputPlaceholder: NSLocalizedString("clinic_appointment_reason_card_title", comment: ""),
            initialText: initialText,
            validationRules: [ RequiredValidationRule() ],
            showValidInputIcon: true,
            keyboardType: .default,
            autocapitalizationType: .sentences,
            charsLimited: .unlimited,
            showMaxCharsLimit: false
        )

        controller.output = .init(
            close: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }, text: { [weak self] text in
                completion(text)
                self?.dismiss(animated: true, completion: nil)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    private func openAnswerTextInput(completion: @escaping (String) -> Void) {
        let controller = TextAreaInputBottomViewController()
        container?.resolve(controller)

        controller.input = .init(
            title: NSLocalizedString("clinic_appointment_disclaimer_title", comment: ""),
            description: input.settings.disclaimer,
            textInputTitle: nil,
            textInputPlaceholder: NSLocalizedString("clinic_appointment_disclaimer_placeholder", comment: ""),
            initialText: data.disclaimerAnswer,
            validationRules: [ RequiredValidationRule() ],
            showValidInputIcon: true,
            keyboardType: .default,
            autocapitalizationType: .sentences,
            charsLimited: .unlimited,
            showMaxCharsLimit: false
        )

        controller.output = .init(
            close: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }, text: { [weak self] text in
                completion(text)
                self?.dismiss(animated: true, completion: nil)
            }
        )

        showBottomSheet(contentViewController: controller)
    }
}
