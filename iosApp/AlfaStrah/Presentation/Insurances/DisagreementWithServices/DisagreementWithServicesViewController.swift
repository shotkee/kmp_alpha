//
//  DisagreementWithServicesViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 23.05.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class DisagreementWithServicesViewController: ViewController,
											  UITableViewDataSource,
											  UITableViewDelegate {
    // MARK: - Input
    struct Input {
        let services: [InsuranceBillDisagreementService]
        let userPhone: Phone
        let userEmail: String
    }
    
    var input: Input!
    
    // MARK: - Output
    struct SubmitData {
        let services: [InsuranceBillDisagreementService]
        let comment: String
        let phone: String?
        let email: String?
    }
    
    struct Output {
        var addDocuments: (BaseDocumentStep) -> Void
        var submit: (SubmitData) -> Void
    }
    
    var output: Output!
    
    // MARK: - Notify
    struct Notify {
        var documentsUpdated: () -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        documentsUpdated: { [weak self] in
            self?.updateDocuments()
        }
    )
    
    // MARK: - UI
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBOutlet private var servicesHeaderLabel: UILabel!
    @IBOutlet private var servicesPromptLabel: UILabel!
    @IBOutlet private var servicesTable: UITableView!
    @IBOutlet private var servicesTableHeightContraint: NSLayoutConstraint!

    @IBOutlet private var commentHeaderLabel: UILabel!
    @IBOutlet private var commentHintLabel: UILabel!
    @IBOutlet private var commentArrowImageView: UIImageView!
    @IBOutlet private var commentCheckmarkImageView: UIImageView!
    @IBOutlet private var commentLabel: UILabel!
    
    @IBOutlet private var contactsHeaderLabel: UILabel!
    @IBOutlet private var contactsPromptLabel: UILabel!
    @IBOutlet private var phoneCheckbox: CommonCheckboxButton!
    @IBOutlet private var phoneLabel: UILabel!
    @IBOutlet private var emailCheckbox: CommonCheckboxButton!
    @IBOutlet private var emailLabel: UILabel!
    
    @IBOutlet private var documentsHeaderLabel: UILabel!
    @IBOutlet private var documentsHintLabel: UILabel!
    @IBOutlet private var documentsCountLabel: UILabel!
    @IBOutlet private var documentsCheckmarkImageView: UIImageView!
    
    @IBOutlet private var personalDataAgreementView: CommonUserAgreementView!
    
    @IBOutlet private var submitButtonContainer: UIView!
    @IBOutlet private var submitButton: RoundEdgeButton!
	
	@IBOutlet private var phoneFieldAccessoryImageView: UIImageView!
	@IBOutlet private var emailFieldAccessoryImageView: UIImageView!
	@IBOutlet private var documentsStateImageView: UIImageView!
	
	// MARK: - Data
    private let documentStep = BaseDocumentStep(
        title: "",
        minDocuments: 0,
        maxDocuments: 0,
        attachments: []
    )
    
    // swiftlint:disable explicit_enum_raw_value
    private enum Sections: Int, CaseIterable {
        case selectAll = 0
        case services
    }
    // swiftlint:enable explicit_enum_raw_value

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adjustScrollInset()
    }
    
    // MARK: - Setup
    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
        // screen title
        
        title = NSLocalizedString("disagreement_with_services", comment: "")
        
        // services
        servicesHeaderLabel.text = NSLocalizedString("disagreement_with_services_services", comment: "")
		servicesHeaderLabel <~ Style.Label.primaryHeadline1
		
        servicesPromptLabel.text = NSLocalizedString("disagreement_with_services_services_prompt", comment: "")
		servicesPromptLabel <~ Style.Label.secondaryText
        
        // comment
        commentHeaderLabel.text = NSLocalizedString("disagreement_with_services_comment", comment: "")
		commentHeaderLabel <~ Style.Label.primaryHeadline1
		
        commentHintLabel.text = NSLocalizedString("disagreement_with_services_comment_hint", comment: "")
		commentHintLabel <~ Style.Label.secondaryText
        
		commentLabel <~ Style.Label.primaryText
        setCommentIsValid(false)
        
        // contacts
        contactsHeaderLabel.text = NSLocalizedString("disagreement_with_services_contacts", comment: "")
		contactsHeaderLabel <~ Style.Label.primaryHeadline1
		
        contactsPromptLabel.text = NSLocalizedString("disagreement_with_services_contacts_prompt", comment: "")
		contactsPromptLabel <~ Style.Label.secondaryText
        
		phoneLabel <~ Style.Label.primaryText
		emailLabel <~ Style.Label.primaryText
		
        // documents
        documentsHeaderLabel.text = NSLocalizedString("disagreement_with_services_documents", comment: "")
		documentsHeaderLabel <~ Style.Label.primaryHeadline1
		
        documentsHintLabel.text = NSLocalizedString("disagreement_with_services_documents_hint", comment: "")
		documentsHintLabel <~ Style.Label.secondaryText
        
		documentsCountLabel <~ Style.Label.primaryCaption1
        
        updateDocuments()
        
        // personal data
        personalDataAgreementView.set(
            text: NSLocalizedString("disagreement_with_services_personal_data_agreement", comment: ""),
            links: [],
            handler: .init(
                userAgreementChanged: { [weak self] _ in
                    self?.updateBottomButtonState()
                }
            )
        )

        // user contacts
        phoneLabel.text = input.userPhone.humanReadable
        emailLabel.text = input.userEmail
        
        // 'disagree' button
        submitButton.setTitle(
            NSLocalizedString("disagreement_with_services_submit", comment: ""),
            for: .normal
        )
        submitButton <~ Style.RoundedButton.oldPrimaryButtonSmall

        updateBottomButtonState()

		servicesTable.backgroundColor = .Background.backgroundSecondary
        setTableHeightUsingAutolayout(
            tableView: servicesTable,
            tableViewHeightContraint: servicesTableHeightContraint
        )
		
		setupAccessoryViews()
    }
	
	private func setupAccessoryViews() {
		let tickImage: UIImage? = .Icons.tick.resized(newWidth: 16)?.tintedImage(withColor: .Icons.iconAccent)
		let chevronImage: UIImage? = .Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary)
		
		commentArrowImageView.image = chevronImage
		commentCheckmarkImageView.image = tickImage
		
		phoneFieldAccessoryImageView.image = chevronImage
		emailFieldAccessoryImageView.image = chevronImage
		documentsStateImageView.image = tickImage
	}
    
    private func setCommentIsValid(_ isValid: Bool) {
        commentArrowImageView.isHidden = isValid
        commentCheckmarkImageView.isHidden = !isValid
    }
    
    private func updateDocuments() {
        documentsCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("files_count", comment: ""),
            documentStep.attachments.count
        )
        
        documentsCheckmarkImageView.isHidden = documentStep.attachments.isEmpty
    }

    private func updateBottomButtonState() {
        let hasSelectedAnyServices = (servicesTable.indexPathsForSelectedRows ?? [])
            .contains(where: { $0.section == Sections.services.rawValue })

        let hasEnteredDisagreementReason = !(commentLabel.text ?? "").isEmpty

        let hasSpecifiedAnyContact = phoneCheckbox.isSelected || emailCheckbox.isSelected

        submitButton.isEnabled = hasSelectedAnyServices
            && hasEnteredDisagreementReason
            && hasSpecifiedAnyContact
            && personalDataAgreementView.userConfirmedAgreement
    }
    
    private func adjustScrollInset() {
        scrollView.contentInset.bottom = submitButtonContainer.bounds.height
    }
    
    // MARK: - Actions
    
    @IBAction private func onDisagreementReasonTap() {
        openTextInputBottomViewController(
            title: NSLocalizedString("disagreement_with_services_comment_prompt", comment: ""),
            initialText: commentLabel.text
        ) { [weak self] text in
            self?.commentLabel.text = text
            self?.setCommentIsValid(!(text ?? "").isEmpty)
            self?.updateBottomButtonState()
        }
    }

    private func openTextInputBottomViewController(
        title: String,
        initialText: String?,
        completion: @escaping (String?) -> Void
    ) {
        let controller: TextAreaInputBottomViewController = .init()
        container?.resolve(controller)
        
        controller.input = .init(
            title: title,
            description: nil,
            textInputTitle: nil,
            textInputPlaceholder: "",
            initialText: initialText,
            validationRules: [],    // disagreement reason is optional
            showValidInputIcon: false,
            keyboardType: .default,
            autocapitalizationType: .sentences,
            charsLimited: .limited(1000),
            showMaxCharsLimit: true
        )

        controller.output = .init(
            close: { [weak self] in
                self?.dismiss(animated: true)
            },
            text: { [weak self] text in
                completion(text)
                self?.dismiss(animated: true)
            }
        )
        
        showBottomSheet(contentViewController: controller)
    }
    
    @IBAction private func onPhoneTap()
    {
        openPhoneInputBottomViewController(
            completion: { [weak self] phone in
                self?.phoneLabel.text = phone.humanReadable
            }
        )
    }
    
    @IBAction private func onEmailTap()
    {
        openEmailInputBottomViewController(
            completion: { [weak self] email in
                self?.emailLabel.text = email
            }
        )
    }
    
    @IBAction func onPhoneCheckbox()
    {
        phoneCheckbox.isSelected.toggle()
        updateBottomButtonState()
    }
    
    @IBAction func onEmailCheckbox()
    {
        emailCheckbox.isSelected.toggle()
        updateBottomButtonState()
    }
    
    private func openPhoneInputBottomViewController(
        completion: @escaping (Phone) -> Void
    ) {
        let controller = PhoneInputBottomViewController()

        controller.input = .init(
            title: NSLocalizedString("disagreement_with_services_phone_number", comment: ""),
            placeholder: NSLocalizedString("disagreement_with_services_phone_number_prompt", comment: ""),
            initialPhoneText: phoneLabel.text
        )
        controller.output = .init(completion: { [weak self] plain, humanReadable in
            let phone = Phone(plain: plain, humanReadable: humanReadable)
            completion(phone)
            self?.dismiss(animated: true, completion: nil)
        })

        showBottomSheet(contentViewController: controller)
    }

    private func openEmailInputBottomViewController(
        completion: @escaping (String) -> Void
    ) {
        let controller = EmailInputBottomViewController()

        controller.input = .init(
            title: NSLocalizedString("disagreement_with_services_email", comment: ""),
            placeholder: NSLocalizedString("disagreement_with_services_email_prompt", comment: ""),
            initialEmailText: emailLabel.text
        )
        controller.output = .init(completion: { [weak self] email in
            completion(email)
            self?.dismiss(animated: true, completion: nil)
        })

        showBottomSheet(contentViewController: controller)
    }
    
    @IBAction func onDocumentsTap()
    {
        output.addDocuments(documentStep)
    }
    
    @IBAction func onSubmitButton()
    {
        guard let services = servicesTable.indexPathsForSelectedRows?
                .filter({ $0.section == Sections.services.rawValue })
                .compactMap({ input.services[safe: $0.row] }),
              let comment = commentLabel.text
        else { return }
        
        output.submit(
            .init(
                services: services,
                comment: comment,
                phone: phoneCheckbox.isSelected ? phoneLabel.text : nil,
                email: emailCheckbox.isSelected ? emailLabel.text : nil
            )
        )
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let section = Sections(rawValue: section)
        else { return 0 }
        
        switch section
        {
            case .selectAll:
                return 1
            case .services:
                return input.services.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let section = Sections(rawValue: indexPath.section)
        else { return UITableViewCell() }
        
        switch section
        {
            case .selectAll:
                let cell = tableView.dequeueReusableCell(DisagreementSelectAllServicesTableCell.id)
                
                return cell
                
            case .services:
                let cell = tableView.dequeueReusableCell(DisagreementServiceTableCell.id)

                if let service = input.services[safe: indexPath.row]
                {
                    cell.configure(
                        index: indexPath.row,
                        service: service
                    )
                }

                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let section = Sections(rawValue: indexPath.section)
        else { return }

        onSelectionChanged(section: section, tableView)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)

    {
        guard let section = Sections(rawValue: indexPath.section)
        else { return }

        onSelectionChanged(section: section, tableView)
    }

    private func onSelectionChanged(section: Sections, _ tableView: UITableView)
    {
        let allSelectedRows = tableView.indexPathsForSelectedRows ?? []

        switch section
        {
            case .selectAll:
                let isSelectAllSelected = allSelectedRows.contains(where: { $0.section == Sections.selectAll.rawValue })

                selectAllServices(isSelectAllSelected, tableView)

            case .services:
                let selectedServices = allSelectedRows.filter { $0.section == Sections.services.rawValue }
                let areAllServicesSelected = selectedServices.count == input.services.count

                let selectAllIndexPath = IndexPath(
                    row: 0,
                    section: Sections.selectAll.rawValue
                )

                if areAllServicesSelected {
                    tableView.selectRow(
                        at: selectAllIndexPath,
                        animated: false,
                        scrollPosition: .none
                    )
                } else {
                    tableView.deselectRow(
                        at: selectAllIndexPath,
                        animated: false
                    )
                }
        }

        updateBottomButtonState()
    }

    private func selectAllServices(_ select: Bool, _ tableView: UITableView)
    {
        input.services.enumerated()
            .forEach
            {
                let indexPath = IndexPath(
                    row: $0.offset,
                    section: Sections.services.rawValue
                )

                if select {
                    tableView.selectRow(
                        at: indexPath,
                        animated: false,
                        scrollPosition: .none
                    )
                } else {
                    tableView.deselectRow(
                        at: indexPath,
                        animated: false
                    )
                }
            }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		setupAccessoryViews()
	}
}
