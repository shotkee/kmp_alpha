//
//  EditBankInfoViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22.01.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class EditBankInfoViewController: ViewController {
    struct Input {
        var eventReport: EventReportAccident
    }

    struct Output {
        var accidentEventReportRules: () -> Void
        var sendChanges: (_ bik: String, _ accountNumber: String) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var actionButton: RoundEdgeButton!

    private let userAgreementView: CommonUserAgreementView = CommonUserAgreementView()

    private var bik: String = ""
    private var accountNumber: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let converted = actionButton.convert(actionButton.bounds, to: scrollView)
        var insets = scrollView.contentInset
        let scrollViewMaxY = scrollView.frame.maxY
        insets.bottom = scrollViewMaxY - converted.origin.y
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    private func setupUI() {
        title = NSLocalizedString("accident_edit_account_number_screen_title", comment: "")
        rootStackView.spacing = 24

        bik = input.eventReport.bik ?? ""
        accountNumber = input.eventReport.accountNumber ?? ""

        let requiredRule = RequiredValidationRule()
        let onlyNumbersRule = OnlyNumbersValidationRule()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        rootStackView.addArrangedSubview(CardView(contentView: stackView))

        let bikInputView: CommonNoteLabelView = .init()
        stackView.addArrangedSubview(bikInputView)
        bikInputView.set(
            title: NSLocalizedString("accident_person_bik_title", comment: ""),
            note: input.eventReport.bik ?? "",
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
                    self.bik = text
                },
                keyboardType: .numberPad
            )
        }
        stackView.addArrangedSubview(separatorView())

        let bankAccountInputView: CommonFieldView = .init()
        stackView.addArrangedSubview(bankAccountInputView)
        bankAccountInputView.isEnabled = false
        bankAccountInputView.set(
            title: NSLocalizedString("accident_person_account_number_short_title", comment: ""),
            text: input.eventReport.accountNumber ?? "",
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

        let link: LinkArea = .init(
            text: NSLocalizedString("accident_edit_account_agreement_terms_label_link_text", comment: ""),
            link: nil
        ) { [weak self] _ in
            self?.output.accidentEventReportRules()
        }
        userAgreementView.set(
            text: NSLocalizedString("accident_edit_account_agreement_terms_label", comment: ""),
            links: [ link ],
            handler: .init(
                userAgreementChanged: { [weak self] _ in
                    self?.updateUI()
                }
            )
        )
        rootStackView.addArrangedSubview(userAgreementView)

        actionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        actionButton.setTitle(NSLocalizedString("accident_edit_account_number_send_button_title", comment: ""), for: .normal)
    }

    private func separatorView() -> HairLineView {
        let sepaartor = HairLineView()
        sepaartor.lineColor = Style.Color.Palette.lightGray
        sepaartor.translatesAutoresizingMaskIntoConstraints = false
        sepaartor.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return sepaartor
    }

    private func updateUI() {
        let isReady = userAgreementView.userConfirmedAgreement && !bik.isEmpty && !accountNumber.isEmpty
        actionButton.isEnabled = isReady
    }

    private func accountTap(
        noteView: CommonNoteProtocol,
        validationRules: [ValidationRule],
        contentMask: String?
    ) {
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
                self.accountNumber = text
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
        textInputMinHeight: CGFloat? = nil
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
            charsLimited: .unlimited,
            scenario: .editBank
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

    @IBAction private func saveChangesTap() {
        output.sendChanges(bik, accountNumber)
    }
}
