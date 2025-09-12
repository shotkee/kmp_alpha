//
//  CreateAccidentEventViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 20.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

private struct EventModel {
    let insuranceId: String
    var claimDate: Date?
    var fullDescription: String?
    var name: String
    var passportSeria: String?
    var passportNumber: String?
    var bik: String?
    var accountNumber: String?
    var documentCount: Int

    init(insurance: Insurance) {
        self.insuranceId = insurance.id
        self.name = insurance.insuredObjectTitle
        self.documentCount = 0
    }

    var passportInfo: String {
        if let passportSeria = passportSeria, let passportNumber = passportNumber {
            return passportSeria + " " + passportNumber
        } else {
            return ""
        }
    }

    var createEventReport: CreateAccidentEventReport? {
        guard
            let claimDate = claimDate,
            let fullDescription = fullDescription,
            let passportSeria = passportSeria,
            let passportNumber = passportNumber,
            let bik = bik,
            let accountNumber = accountNumber
        else { return nil }

        return CreateAccidentEventReport(insuranceId: insuranceId, fullDescription: fullDescription, documentCount: documentCount,
            claimDate: claimDate, timezone: claimDate, beneficiary: name, passportSeria: passportSeria, passportNumber: passportNumber,
            bik: bik, accountNumber: accountNumber)
    }

    var isValid: Bool {
        createEventReport != nil
    }
}

class CreateAccidentEventViewController: ViewController, AttachmentServiceDependency {
    var attachmentService: AttachmentService!

    struct Input {
        var insurance: Insurance
    }

    struct Output {
        var linkTap: (URL) -> Void
        var accidentEventReportRules: () -> Void
        var addPhoto: (BaseDocumentStep) -> Void
        var createEvent: (CreateAccidentEventReport, BaseDocumentStep, _ completion: @escaping () -> Void) -> Void
    }

    struct Notify {
        var photosUpdated: () -> Void
    }

    var input: Input!
    var output: Output!

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        photosUpdated: { [weak self] in
            self?.eventReport.documentCount = self?.documentStep.attachments.count ?? 0
            self?.updateUI()
        }
    )

    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!

    private let filePickerView = CommonFilePickerView()
    private let userAgreementView = CommonUserAgreementView()
    private let actionButton = RoundEdgeButton()
    private lazy var eventReport = EventModel(insurance: input.insurance)
    private let documentStep = BaseDocumentStep(
        title: NSLocalizedString("accident_event_photo_galary_title", comment: ""),
        minDocuments: 1,
        maxDocuments: 200,
        attachments: []
    )

    private var allFieldsVerified: Bool {
        eventReport.isValid && documentStep.isReady && userAgreementView.userConfirmedAgreement
    }

    deinit {
        // Delete photos from disk
        documentStep.attachments.forEach { attachmentService.delete(attachment: $0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("insurance_accident_create_screen_title", comment: "")
        rootStackView.spacing = 0

        setupEventInfoSection()
        rootStackView.addArrangedSubview(spacer(12))
        setupNoteInfoSection()
        rootStackView.addArrangedSubview(spacer(24))
        setupPersonInfoSection()
        rootStackView.addArrangedSubview(spacer(12))

        // Photo info section

        rootStackView.addArrangedSubview(CardView(contentView: filePickerView))
        filePickerView.tapHandler = { [unowned self] in
            self.addFileTap()
        }

        rootStackView.addArrangedSubview(spacer(12))

        let photoSectionTextLabel = UILabel()
        rootStackView.addArrangedSubview(photoSectionTextLabel)
        photoSectionTextLabel <~ Style.Label.secondaryCaption1
        photoSectionTextLabel.numberOfLines = 0
        photoSectionTextLabel.text = NSLocalizedString("accident_photo_section_text", comment: "")
        
        rootStackView.addArrangedSubview(spacer(8))
        
        let idSectionTextLabel = UILabel()
        rootStackView.addArrangedSubview(idSectionTextLabel)
        idSectionTextLabel <~ Style.Label.accentCaption1
        idSectionTextLabel.numberOfLines = 0
        idSectionTextLabel.text = NSLocalizedString("accident_id_section_text", comment: "")
        
        rootStackView.addArrangedSubview(spacer(24))

        let link: LinkArea = .init(
            text: NSLocalizedString("accident_agreement_terms_label_link_text", comment: ""),
            link: nil
        ) { [weak self] _ in
            self?.output.accidentEventReportRules()
        }
        userAgreementView.set(
            text: NSLocalizedString("accident_agreement_terms_label", comment: ""),
            links: [ link ],
            handler: .init(
                userAgreementChanged: { [weak self] _ in
                    self?.updateUI()
                }
            )
        )
        rootStackView.addArrangedSubview(userAgreementView)

        rootStackView.addArrangedSubview(spacer(48))

        // Action button section

        rootStackView.addArrangedSubview(actionButton)
        actionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        actionButton.setTitle(NSLocalizedString("accident_action_button_title", comment: ""), for: .normal)
        actionButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        actionButton.addTarget(self, action: #selector(createInsuranceEventTap), for: .touchUpInside)

        updateUI()
    }

    private func separatorView() -> HairLineView {
        let sepaartor = HairLineView()
		sepaartor.lineColor = .Stroke.divider
        sepaartor.translatesAutoresizingMaskIntoConstraints = false
        sepaartor.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return sepaartor
    }

    private func setupEventInfoSection() {
        let requiredRule = RequiredValidationRule()

        let eventSectionTitleLabel = UILabel()
        rootStackView.addArrangedSubview(eventSectionTitleLabel)
        eventSectionTitleLabel <~ Style.Label.primaryHeadline1
        eventSectionTitleLabel.text = NSLocalizedString("accident_event_section_title", comment: "")

        rootStackView.addArrangedSubview(spacer(6))

        let eventSectionTextLabel = UILabel()
        rootStackView.addArrangedSubview(eventSectionTextLabel)
        eventSectionTextLabel <~ Style.Label.secondaryCaption1
        eventSectionTextLabel.numberOfLines = 0
        eventSectionTextLabel.text = NSLocalizedString("accident_event_section_text", comment: "")

        if input.insurance.helpURL != nil {
            rootStackView.addArrangedSubview(spacer(8))

            let linkLabel = UILabel()
            rootStackView.addArrangedSubview(linkLabel)
            linkLabel.isUserInteractionEnabled = true
            linkLabel <~ Style.Label.accentCaption1
            linkLabel.numberOfLines = 0
            linkLabel.text = NSLocalizedString("accident_event_help_link_text", comment: "")
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openHelpLinkTap))
            linkLabel.addGestureRecognizer(tapGestureRecognizer)
        }

        rootStackView.addArrangedSubview(spacer(12))

        let dateInputView: CommonNoteLabelView = .init()
		dateInputView.backgroundColor = .Background.backgroundSecondary
        rootStackView.addArrangedSubview(CardView(contentView: dateInputView))
        dateInputView.set(
            title: NSLocalizedString("accident_event_report_event_date_title", comment: ""),
            note: eventReport.claimDate.map(AppLocale.dateString) ?? "",
            placeholder: NSLocalizedString("accident_event_report_event_date_hint", comment: ""),
            style: .center(UIImage(named: "right_arrow_icon_gray")),
            margins: Style.Margins.defaultInsets,
            showSeparator: false,
            validationRules: [ requiredRule ]
        )
        dateInputView.tapHandler = { [unowned self] in
            self.selectDateTap(dateInputView)
        }
    }

    private func setupNoteInfoSection() {
        let requiredRule = RequiredValidationRule()

        let notetInputView: CommonNoteLabelView = .init()
		notetInputView.backgroundColor = .Background.backgroundSecondary
        rootStackView.addArrangedSubview(CardView(contentView: notetInputView))
        let noteMinHeight: CGFloat = 150
        notetInputView.translatesAutoresizingMaskIntoConstraints = false
        notetInputView.heightAnchor.constraint(equalToConstant: noteMinHeight).isActive = true

        notetInputView.set(
            title: NSLocalizedString("accident_event_report_event_note_title", comment: ""),
            note: eventReport.fullDescription ?? "",
            placeholder: NSLocalizedString("accident_event_report_event_note_hint", comment: ""),
            style: .top(UIImage(named: "right_arrow_icon_gray")),
            margins: Style.Margins.defaultInsets,
            showSeparator: false,
            validationRules: [ requiredRule ]
        )
        notetInputView.tapHandler = { [unowned self] in
            self.textInputTap(
                title: NSLocalizedString("accident_event_report_event_note_title", comment: ""),
                textHint: nil,
                textInputTitle: nil,
                textInputPlaceholder: NSLocalizedString("accident_event_report_event_note_hint", comment: ""),
                validationRules: [ requiredRule ],
                noteView: notetInputView,
                inputHandler: { [unowned self] text in
                    self.eventReport.fullDescription = text
                },
                textInputMinHeight: noteMinHeight,
                charsInputLimit: .limited(1500)
            )
        }
    }

    private func setupPersonInfoSection() {
        let requiredRule = RequiredValidationRule()
        let onlyNumbersRule = OnlyNumbersValidationRule()

        let personSectionTitleLabel = UILabel()
        rootStackView.addArrangedSubview(personSectionTitleLabel)
        personSectionTitleLabel <~ Style.Label.primaryHeadline1
        personSectionTitleLabel.text = NSLocalizedString("accident_person_section_title", comment: "")

        rootStackView.addArrangedSubview(spacer(6))

        let personSectionTextLabel = UILabel()
        rootStackView.addArrangedSubview(personSectionTextLabel)
        personSectionTextLabel <~ Style.Label.secondaryCaption1
        personSectionTextLabel.numberOfLines = 0
        personSectionTextLabel.text = NSLocalizedString("accident_person_section_text", comment: "")

        rootStackView.addArrangedSubview(spacer(12))

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        rootStackView.addArrangedSubview(CardView(contentView: stackView))

        let nameInputView: CommonNoteLabelView = .init()
		nameInputView.backgroundColor = .Background.backgroundSecondary
        stackView.addArrangedSubview(nameInputView)
        nameInputView.set(
            title: NSLocalizedString("accident_person_name_title", comment: ""),
            note: eventReport.name,
            placeholder: NSLocalizedString("accident_person_name_hint", comment: ""),
            style: .center(nil),
            margins: Style.Margins.defaultInsets,
            showSeparator: false,
            validationRules: [ RequiredValidationRule() ]
        )
        stackView.addArrangedSubview(separatorView())

        let passportInputView: CommonNoteLabelView = .init()
		passportInputView.backgroundColor = .Background.backgroundSecondary
        stackView.addArrangedSubview(passportInputView)
        passportInputView.set(
            title: NSLocalizedString("accident_person_passport_title", comment: ""),
            note: eventReport.passportInfo,
            placeholder: NSLocalizedString("accident_person_passport_hint", comment: ""),
            style: .center(UIImage(named: "right_arrow_icon_gray")),
            margins: Style.Margins.defaultInsets,
            showSeparator: false,
            validationRules: [ RequiredValidationRule() ]
        )
        passportInputView.tapHandler = { [unowned self] in
            self.changePassportTap(passportInputView)
        }
        stackView.addArrangedSubview(separatorView())

        let bikInputView: CommonNoteLabelView = .init()
		bikInputView.backgroundColor = .Background.backgroundSecondary
        stackView.addArrangedSubview(bikInputView)
        bikInputView.set(
            title: NSLocalizedString("accident_person_bik_title", comment: ""),
            note: eventReport.bik ?? "",
            placeholder: NSLocalizedString("accident_person_bik_hint", comment: ""),
            style: .center(UIImage(named: "right_arrow_icon_gray")),
            margins: Style.Margins.defaultInsets,
            showSeparator: false,
            validationRules: [ requiredRule ]
        )
        bikInputView.tapHandler = { [unowned self] in
            self.textInputTap(
                title: NSLocalizedString("accident_person_bik_title", comment: ""),
                textHint: nil,
                textInputTitle: nil,
                textInputPlaceholder: NSLocalizedString("accident_person_bik_hint", comment: ""),
                showSeparator: true,
                validationRules: [ requiredRule, onlyNumbersRule ],
                noteView: bikInputView,
                inputHandler: { [unowned self] text in
                    self.eventReport.bik = text
                },
                keyboardType: .numberPad
            )
        }
        stackView.addArrangedSubview(separatorView())

        let bankAccountInputView: CommonFieldView = .init()
		bankAccountInputView.backgroundColor = .Background.backgroundSecondary
        stackView.addArrangedSubview(bankAccountInputView)
        bankAccountInputView.isEnabled = false
        bankAccountInputView.set(
            title: NSLocalizedString("accident_person_account_number_short_title", comment: ""),
            text: eventReport.accountNumber ?? "",
            placeholder: NSLocalizedString("accident_person_account_number_hint", comment: ""),
            icon: UIImage(named: "right_arrow_icon_gray"),
            margins: Style.Margins.defaultInsets,
            showSeparator: false,
            validationRules: [ requiredRule ],
            contentMask: ContentMasks.noteAccountNumber
        )
        bankAccountInputView.tapHandler = { [unowned self] in
            self.accountTap(
                noteView: bankAccountInputView,
                validationRules: [ LengthValidationRule(countChars: 20), OnlyNumbersValidationRule() ],
                contentMask: ContentMasks.inputAccountNumber
            )
        }
    }

    private func updateUI() {
        actionButton.isEnabled = allFieldsVerified
        filePickerView.set(
            filesCount: documentStep.attachments.count,
            margins: Style.Margins.defaultInsets,
            allFilesPresent: documentStep.isReady && !documentStep.attachments.isEmpty
        )
    }

    private func selectDateTap(_ noteView: CommonNoteProtocol) {
        let controller: DateInputBottomViewController = .init()
        self.container?.resolve(controller)

        guard let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        else { return }
                
        controller.input = .init(
            title: NSLocalizedString("accident_event_date_picker_title", comment: ""),
            mode: .date,
            date: eventReport.claimDate ?? dayBefore,
            maximumDate: dayBefore,
            minimumDate: nil
        )

        controller.output = .init(
            close: {
                self.dismiss(animated: true, completion: nil)
            },
            selectDate: { date in
                noteView.updateText(AppLocale.dateString(date))
                noteView.validate()
                self.eventReport.claimDate = date
                self.updateUI()
                self.dismiss(animated: true, completion: nil)
            }
        )

        showBottomSheet(
            contentViewController: controller,
            dragEnabled: true,
            dismissCompletion: nil
        )
    }

    private func changePassportTap(_ noteView: CommonNoteProtocol) {
        let controller: InputBottomViewController = .init()
        container?.resolve(controller)

        let seriaInput = InputBottomViewController.InputObject(
            text: eventReport.passportSeria,
            placeholder: NSLocalizedString("accident_person_passport_series_hint", comment: ""),
            keyboardType: .default,
            validationRule: [ RequiredValidationRule() ]
        )

        let numberInput = InputBottomViewController.InputObject(
            text: eventReport.passportNumber,
            placeholder: NSLocalizedString("accident_person_passport_number_hint", comment: ""),
            keyboardType: .numberPad,
            validationRule: [ RequiredValidationRule() ]
        )

        controller.input = .init(
            title: NSLocalizedString("accident_person_passport_title", comment: ""),
            infoText: "",
            inputs: [ seriaInput, numberInput ]
        )
        controller.output = .init(
            close: {
                self.dismiss(animated: true)
            },
            done: { [unowned self] result in
                self.eventReport.passportSeria = result[seriaInput.id] ?? ""
                self.eventReport.passportNumber = result[numberInput.id] ?? ""

                noteView.updateText(self.eventReport.passportInfo)
                noteView.validate()

                self.updateUI()
                self.dismiss(animated: true)
            }
        )

        showBottomSheet(contentViewController: controller)
    }

    func accountTap(noteView: CommonNoteProtocol, validationRules: [ValidationRule] = [], contentMask: String? = nil) {
        let controller: AccountInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            accountNumber: noteView.currentText,
            validationRules: validationRules,
            contentMask: contentMask
        )
        controller.output = .init(
            close: {
                self.dismiss(animated: true, completion: nil)
            },
            number: { text in
                self.eventReport.accountNumber = text
                noteView.updateText(text)
                noteView.validate()
                self.updateUI()
                self.dismiss(animated: true, completion: nil)
            }
        )
        showBottomSheet(contentViewController: controller, dragEnabled: true, dismissCompletion: nil)
    }

    private func textInputTap(
        title: String,
        textHint: String?,
        textInputTitle: String?,
        textInputPlaceholder: String,
        showSeparator: Bool = false,
        validationRules: [ValidationRule],
        noteView: CommonNoteProtocol,
        inputHandler: @escaping (String) -> Void,
        keyboardType: UIKeyboardType = .default,
        textInputMinHeight: CGFloat? = nil,
        charsInputLimit: CharsInputLimits = .unlimited
    ) {
        let controller: TextNoteInputBottomViewController = .init()
        self.container?.resolve(controller)

        controller.input = .init(
            title: title,
            description: textHint,
            textInputTitle: textInputTitle,
            textInputPlaceholder: textInputPlaceholder,
            initialText: noteView.currentText,
            showSeparator: showSeparator,
            validationRules: validationRules,
            keyboardType: keyboardType,
            textInputMinHeight: textInputMinHeight,
            charsLimited: charsInputLimit,
            scenario: .accidentEvent
        )

        controller.output = .init(
            close: {
                self.dismiss(animated: true, completion: nil)
            },
            text: { text in
                noteView.updateText(text)
                noteView.validate()
                inputHandler(text)
                self.updateUI()
                self.dismiss(animated: true, completion: nil)
            }
        )

        showBottomSheet(contentViewController: controller, dragEnabled: true, dismissCompletion: nil)
    }

    @objc private func openHelpLinkTap() {
        guard let helpUrl = input.insurance.helpURL else { return }

        output.linkTap(helpUrl)
    }

    private func addFileTap() {
        output.addPhoto(documentStep)
    }

    @objc private func createInsuranceEventTap() {
        guard let eventReport = eventReport.createEventReport else { return }

        actionButton.isEnabled = false
        let hide = showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
        output.createEvent(eventReport, documentStep) { [weak self] in
            hide(nil)
            self?.actionButton.isEnabled = true
        }
    }
}
