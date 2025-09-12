//
//  AccidentEventReportViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.11.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class AccidentEventReportViewController: ViewController, AttachmentServiceDependency {
    var attachmentService: AttachmentService!
    struct Input {
        var insurance: Insurance
        var eventReport: EventReportAccident
    }

    struct Output {
        var chat: () -> Void
        var addDocuments: (BaseDocumentStep) -> Void
        var editBankInfo: () -> Void
        let showPaymentApplicationPdf: ((_ insuranceId: String, _ eventReportId: String) -> Void)?
    }

    struct Notify {
        var photosUpdated: () -> Void
    }

    var input: Input!
    var output: Output!

    // swiftlint:disable:next trailing_closure
    lazy private(set) var notify: Notify = Notify(
        photosUpdated: { [weak self] in
            self?.updateUI()
        }
    )

    @IBAction private func showPaymentApplicationPdfTap(_ sender: Any) {
        self.output.showPaymentApplicationPdf?(self.input.insurance.id, self.input.eventReport.id)
    }
    
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBOutlet private var attentionLabel: UILabel!
    @IBOutlet private var eventSectionTextLabel: UILabel!
    @IBOutlet private var eventStatusStackView: UIStackView!
    @IBOutlet private var eventInfoStackView: UIStackView!
    @IBOutlet private var documentsUploadInfoStackView: UIStackView!
    @IBOutlet private var documentsUploadInfoView: CommonDocumentsUploadInfoView!
    @IBOutlet private var editBankInfoStackView: UIStackView!
    @IBOutlet private var actionButton: RoundEdgeButton!

    // add documents section
    @IBOutlet private var addDocumentsStackView: UIStackView!
    @IBOutlet private var addDocumentsTitleLabel: UILabel!
    @IBOutlet private var addDocumentsTextLabel: UILabel!
    @IBOutlet private var addDocumentsHintLabel: UILabel!
    @IBOutlet private var addDocumentsButton: RoundEdgeButton!

	@IBOutlet private var attentionIconImageView: UIImageView!
	
	private let documentStep: BaseDocumentStep = .init(
        title: NSLocalizedString("accident_event_photo_galary_title", comment: ""),
        minDocuments: 1,
        maxDocuments: 50,
        attachments: []
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: actionButton.frame.height + 8, right: 0)
    }

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
		attentionIconImageView.image = UIImage(named: "ico-insp-manual")?.tintedImage(withColor: .Icons.iconAccent)
		
        title = input.eventReport.number

        eventSectionTextLabel.numberOfLines = 0
        eventSectionTextLabel.text = input.eventReport.statusDescription
        eventSectionTextLabel <~ Style.Label.secondaryCaption1
        
        attentionLabel <~ Style.Label.primaryText
        attentionLabel.text = NSLocalizedString("accident_event_your_application", comment: "")

        let statusInputView: CommonNoteLabelView = .init()
        eventStatusStackView.addArrangedSubview(statusInputView)
        statusInputView.set(
            title: NSLocalizedString("accident_event_status_title", comment: ""),
            note: input.eventReport.status,
            placeholder: "",
			style: .center(
				input.eventReport.statusKind.icon?
					.tintedImage(withColor: .Icons.iconAccent)
					.withRenderingMode(.alwaysTemplate)
			),
            margins: Style.Margins.defaultInsets,
            showSeparator: false,
            appearance: .header
        )

        let dateInputView: CommonNoteLabelView = .init()
        eventInfoStackView.addArrangedSubview(dateInputView)
        dateInputView.set(
            title: NSLocalizedString("accident_event_report_event_date_title", comment: ""),
            note: AppLocale.dateString(input.eventReport.createDate),
            placeholder: "",
            margins: Style.Margins.defaultInsets,
            showSeparator: false
        )
        eventInfoStackView.addArrangedSubview(separatorView())
        let eventInputView: CommonNoteLabelView = .init()
        eventInfoStackView.addArrangedSubview(eventInputView)
        eventInputView.set(
            title: NSLocalizedString("accident_event_event_title", comment: ""),
            note: input.eventReport.event,
            placeholder: "",
            margins: Style.Margins.defaultInsets,
            showSeparator: false
        )

        documentsUploadInfoView.set(margins: Style.Margins.defaultInsets)
		documentsUploadInfoView.backgroundColor = .Background.backgroundSecondary

        actionButton <~ Style.RoundedButton.oldOutlinedButtonSmall
        actionButton.setTitle(NSLocalizedString("common_ask_chat", comment: ""), for: .normal)

        setupAddDocumentsSection()
        setupEditBankInfoSection()

        updateUI()
    }

    private func setupAddDocumentsSection() {
        addDocumentsTitleLabel <~ Style.Label.primaryHeadline1
        addDocumentsTitleLabel.text = NSLocalizedString("accident_event_add_photos_title", comment: "")
        addDocumentsTextLabel <~ Style.Label.secondaryText
        addDocumentsTextLabel.text = NSLocalizedString("accident_event_add_photos_text", comment: "")
        addDocumentsHintLabel <~ Style.Label.secondaryCaption1
        addDocumentsHintLabel.text = NSLocalizedString("accident_event_add_photos_hint", comment: "")
        addDocumentsButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        addDocumentsButton.setTitle(NSLocalizedString("accident_event_add_photos_button_title", comment: ""), for: .normal)

        addDocumentsStackView.isHidden = !input.eventReport.canAddPhotos
    }

    private func setupEditBankInfoSection() {
        guard input.eventReport.canEditPayout else { return }

        let hintConrainerView = UIView()
        editBankInfoStackView.addArrangedSubview(hintConrainerView)
        let hintLabel = UILabel()
        hintConrainerView.addSubview(hintLabel)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: hintLabel, in: hintConrainerView, margins: Style.Margins.defaultInsets))
        hintLabel <~ Style.Label.secondaryText
        hintLabel.numberOfLines = 0
        hintLabel.text = NSLocalizedString("accident_person_account_number_hint_title", comment: "")

        if let bik = input.eventReport.bik {
            let bikView: CommonNoteLabelView = .init()
            editBankInfoStackView.addArrangedSubview(bikView)
            bikView.set(
                title: NSLocalizedString("accident_person_bik_title", comment: ""),
                note: bik,
                placeholder: "",
                margins: Style.Margins.defaultInsets,
                showSeparator: false
            )

            editBankInfoStackView.addArrangedSubview(separatorView())
        }

        if let accountNumber = input.eventReport.accountNumber {
            let accountNumberView: CommonFieldView = .init()
            editBankInfoStackView.addArrangedSubview(accountNumberView)
            accountNumberView.isEnabled = false
            accountNumberView.set(
                title: NSLocalizedString("accident_person_account_number_short_title", comment: ""),
                text: accountNumber,
                placeholder: "",
                icon: nil,
                margins: Style.Margins.defaultInsets,
                showSeparator: false,
                contentMask: ContentMasks.noteAccountNumber
            )

            editBankInfoStackView.addArrangedSubview(separatorView())
        }

        let buttonConrainerView = UIView()
        editBankInfoStackView.addArrangedSubview(buttonConrainerView)
        let actionButton = RoundEdgeButton()
        buttonConrainerView.addSubview(actionButton)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: actionButton, in: buttonConrainerView,
            margins: UIEdgeInsets(top: 18, left: Style.Margins.default, bottom: 24, right: Style.Margins.default)))
        actionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        actionButton.setTitle(NSLocalizedString("accident_edit_account_number_button_title", comment: ""), for: .normal)
        actionButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        actionButton.addTarget(self, action: #selector(editBankInfoTap), for: .touchUpInside)
    }

    private func separatorView() -> HairLineView {
        let sepaartor = HairLineView()
		sepaartor.lineColor = .Stroke.divider
        sepaartor.translatesAutoresizingMaskIntoConstraints = false
        sepaartor.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return sepaartor
    }

    private func subscribeToUploads() {
        attachmentService.subscribeToUploads { [weak self] in
            self?.updateUI()
        }.disposed(by: disposeBag)
    }

    private func updateUI() {
        if let status = attachmentService.uploadStatus(eventReportId: input.eventReport.id), !status.finished {
            documentsUploadInfoStackView.isHidden = false
            documentsUploadInfoView.set(uploadedFilesCount: status.uploadedDocumentsCount, totalFilesCount: status.totalDocumentsCount)
        } else {
            documentsUploadInfoStackView.isHidden = true
        }
    }

    @IBAction private func actionButtonTap() {
        output.chat()
    }

    @IBAction private func addDocumentsButtonTap() {
        output.addDocuments(documentStep)
    }

    @objc private func editBankInfoTap() {
        output.editBankInfo()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		let image = attentionIconImageView.image
		
		attentionIconImageView.image = image?.tintedImage(withColor: .Icons.iconAccent)
	}
}
