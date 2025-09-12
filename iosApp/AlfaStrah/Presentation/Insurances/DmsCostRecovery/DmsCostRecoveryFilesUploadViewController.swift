//
//  DmsCostRecoveryFilesUploadViewController.swift
//  AlfaStrah
//
//  Created by vit on 16.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoveryFilesUploadViewController: ViewController, AttachmentServiceDependency {
    var attachmentService: AttachmentService!
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    
    private let costRecoveryTypeSelectionView = TitledValueCardView()
    private let sendDocumentsButton = RoundEdgeButton()
    private let documentsSection = UIStackView()
    private let personalAgreementView = CommonUserAgreementView()
    
    private let uploadStatusView = StatusCardView()
    private var uploadStatusContainerView = UIView()
    
    private var warningBannerView: DmsCostRecoveryWarningBannerView?
    
    struct Notify {
        let uploadStatusChanged: (_ newSize: Int64) -> Void
        let documentAttachmentsUpdated: (DmsCostRecoveryDocumentsList, [Attachment]) -> Void
        let isSendButtonEnabled: (_ enabled: Bool) -> Void
        let applicationConfirmed: (_ applicationResponse: DmsCostRecoveryApplicationResponse) -> Void
    }
    
    private(set) lazy var notify = Notify(
        uploadStatusChanged: { [weak self] bytesCount in
            guard let self = self
            else { return }
            
            let sizeString = self.bytesCountFormatted(from: bytesCount)
            self.setUploadSizeView(value: sizeString)
            
            self.showWarningBanner = bytesCount > Constants.sizeUpperBound * 1048576
        },
        documentAttachmentsUpdated: { [weak self] document, attachments in
            self?.update(for: document, with: attachments)
        },
        isSendButtonEnabled: { [weak self] enabled in
            self?.sendDocumentsButton.isEnabled = enabled
        },
        applicationConfirmed: { [weak self] applicationaResponse in
            self?.setupAgreement(with: applicationaResponse)
        }
    )
    
    struct Input {
        let documentsInfo: DmsCostRecoveryDocumentsInfo
    }
    
    var input: Input!
    
    struct Output {
        let sendDocuments: () -> Void
        let selectRecoveryType: (@escaping (DmsCostRecoveryDocumentsByType) -> Void) -> Void
        let showDocument: (URL) -> Void
        let selectFilesForUpload: (DmsCostRecoveryDocumentsList) -> Void
        let updateAgreementState: (Bool) -> Void
    }
    
    var output: Output!
    
    private var showWarningBanner: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .Background.backgroundContent
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        costRecoveryTypeSelectionView.set(
            title: NSLocalizedString("dms_cost_recovery_upload_recovery_type_request_title", comment: ""),
            subTitle: NSLocalizedString("dms_cost_recovery_upload_recovery_type_title", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_default_info_empty_state", comment: ""),
            value: nil,
            isRequiredField: true
        )
        
        costRecoveryTypeSelectionView.tapHandler = { [weak self] in
            self?.output.selectRecoveryType { [weak self] selectedType in
                guard let self = self
                else { return }
                
                self.costRecoveryTypeSelectionView.updateValue(selectedType.title)
                self.showDocuments(for: selectedType)
                self.uploadStatusContainerView.isHidden = false
                self.personalAgreementView.isHidden = false
            }
        }
        
        contentStackView.addArrangedSubview(costRecoveryTypeSelectionView)
        
        fillDocumentsSection()

        addSendDocumentsButton()
    }
    let format = NSLocalizedString("dms_cost_recovery_upload_files_size_bounds_template", comment: "")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if showWarningBanner {
            let format = NSLocalizedString("dms_cost_recovery_upload_files_size_exceed_error_description", comment: "")
            
            showWarning(text: String(format: format, "\(Constants.sizeUpperBound)"))
            showWarningBanner = false
        }
        
        personalAgreementView.resetConfirmation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.contentInset.bottom != actionButtonsStackView.bounds.height {
            scrollView.contentInset.bottom = actionButtonsStackView.bounds.height
        }
    }
        
    private func addDocumentsCards(for type: DmsCostRecoveryDocumentsByType) {
        for documentsList in type.documentsLists {
            let view = TitledValueCardView()
            view.set(
                title: documentsList.fullTitle,
                subTitle: NSLocalizedString("dms_cost_recovery_upload_recovery_attach_documents", comment: ""),
                placeholder: NSLocalizedString("dms_cost_recovery_upload_recovery_no_files", comment: ""),
                icon: .photo,
                isRequiredField: documentsList.isRequired
            )
            
            view.tapHandler = { [weak self] in
                self?.output.selectFilesForUpload(documentsList)
                self?.personalAgreementView.resetConfirmation()
            }
            
            documentsSection.addArrangedSubview(view)
            view.isHidden = true
        }
    }
    
    private func bytesCountFormatted(from bytesCount: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytesCount)
    }
    
    private func addSendDocumentsButton() {
        sendDocumentsButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        sendDocumentsButton.setTitle(
            NSLocalizedString("dms_cost_recovery_send_uploaded_files", comment: ""),
            for: .normal
        )
        sendDocumentsButton.addTarget(self, action: #selector(sendDocumentsButtonTap), for: .touchUpInside)
        sendDocumentsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendDocumentsButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(sendDocumentsButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 18, right: 18)
        
        sendDocumentsButton.isEnabled = false
    }
    
    private func addUploadSizeView() {
        setUploadSizeView(value: NSLocalizedString("dms_cost_recovery_upload_files_size_bounds_default_value", comment: ""))

        uploadStatusContainerView = uploadStatusView.embedded(hasShadow: true)
        documentsSection.addArrangedSubview(uploadStatusContainerView)
        
        uploadStatusContainerView.isHidden = true
    }
    
    private func setUploadSizeView(value: String) {
        let format = NSLocalizedString("dms_cost_recovery_upload_files_size_bounds_template", comment: "")
        
        uploadStatusView.configure(
            title: NSLocalizedString("dms_cost_recovery_upload_files_size_title", comment: ""),
            description: String(format: format, value, "\(Constants.sizeUpperBound)")
        )
    }
    
    private func setupAgreement(with applicationResponse: DmsCostRecoveryApplicationResponse) {
        let links: [LinkArea] = applicationResponse.details.links.map { link in
            LinkArea(
                text: link.text,
                link: URL(string: link.path),
                tapHandler: { url in
                    guard let url = url
                    else { return }
                    
                    self.output.showDocument(url)
                }
            )
        }
        
        personalAgreementView.set(
            text: applicationResponse.details.text,
            links: links,
            handler: .init(
                userAgreementChanged: { [weak self] checked in
                    self?.output.updateAgreementState(checked)
                }
            )
        )
        personalAgreementView.isHidden = true
    }
    
    private func addAgreement() {
		let viewContainer = UIView()
		viewContainer.addSubview(personalAgreementView)
		personalAgreementView.horizontalToSuperview(insets: .horizontal(18))
		personalAgreementView.topToSuperview(offset: 6)
		personalAgreementView.bottomToSuperview(offset: 30)
        documentsSection.addArrangedSubview(viewContainer)
    }
    
    private func fillDocumentsSection() {
        documentsSection.spacing = 24
        documentsSection.axis = .vertical
        contentStackView.addArrangedSubview(documentsSection)
        
        for type in input.documentsInfo.documentsByType {
            addDocumentsCards(for: type)
        }
        
        addUploadSizeView()
        addAgreement()
    }
    
    private func showDocuments(for selectedType: DmsCostRecoveryDocumentsByType) {
        var viewIndexInDocumentSection = 0
        for type in self.input.documentsInfo.documentsByType {
            for _ in type.documentsLists {
                self.documentsSection.subviews[viewIndexInDocumentSection].isHidden = type != selectedType
                viewIndexInDocumentSection += 1
            }
        }
    }
    
    private func removePreviousWarningBannerViewIfNeeded() {
        guard let warningBannerView = self.warningBannerView
        else { return }
        
        if warningBannerView.isDescendant(of: view) {
            warningBannerView.removeFromSuperview()
        }
        
        self.warningBannerView = nil
    }
    
    func showWarning(text: String) {
        removePreviousWarningBannerViewIfNeeded()
        
        let warningBannerView: DmsCostRecoveryWarningBannerView = .fromNib()
        
        self.warningBannerView = warningBannerView
        
        warningBannerView.translatesAutoresizingMaskIntoConstraints = false
        
        if let navigationController = self.navigationController {
            let statusBarHeight = UIApplication.shared.statusBarFrame.size.height

            navigationController.view.addSubview(warningBannerView)
            
            NSLayoutConstraint.activate([
                warningBannerView.topAnchor.constraint(equalTo: navigationController.view.topAnchor, constant: statusBarHeight + 5),
                warningBannerView.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor, constant: 18),
                warningBannerView.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor, constant: -18)
            ])
            
            let bannerViewOffset = warningBannerView.frame.origin.y + warningBannerView.frame.height
            
            warningBannerView.set(
                appearance: .gray,
                text: text,
                startBannerOffset: -(bannerViewOffset + statusBarHeight)
            )
        }
    }
    
    private func update(for documentsList: DmsCostRecoveryDocumentsList, with attachments: [Attachment]) {
        var viewIndexInDocumentSection = 0
        
        for type in input.documentsInfo.documentsByType {
            for temp in type.documentsLists {
                if documentsList == temp {
                    guard let view = documentsSection.subviews[viewIndexInDocumentSection] as? TitledValueCardView
                    else { return }
                    
                    if attachments.isEmpty {
                        view.set(
                            title: documentsList.fullTitle,
                            subTitle: NSLocalizedString("dms_cost_recovery_upload_recovery_attach_documents", comment: ""),
                            placeholder: NSLocalizedString("dms_cost_recovery_upload_recovery_no_files", comment: ""),
                            icon: .photo,
                            isRequiredField: documentsList.isRequired
                        )
                    } else {
                        let totalAttachmentsSize = attachments.reduce(0) { $0 + (attachmentService.size(from: $1.url) ?? 0) }
                        let totalAttachmentsSizeString = bytesCountFormatted(from: totalAttachmentsSize)
                        let attributedString = addAttributedRedPostfix(
                            text: NSLocalizedString("dms_cost_recovery_upload_recovery_attach_documents", comment: ""),
                            postfix: totalAttachmentsSizeString
                        )
                        view.updateSubtitle(with: attributedString)
                        
                        view.updateValue(String.localizedStringWithFormat(
                            NSLocalizedString("files_count", comment: ""),
                            attachments.count
                        ))
                    }
                }
                
                viewIndexInDocumentSection += 1
            }
        }
    }
    
    private func addAttributedRedPostfix(text: String, postfix: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: text)
        
        let attributedPostfix = NSMutableAttributedString(
            string: " (" + postfix + ")",
            attributes: [
                .foregroundColor: Style.Color.Palette.red
            ]
        )
        attributedText.append(attributedPostfix)
        
        return attributedText
    }
                
    @objc func sendDocumentsButtonTap(_ sender: UIButton) {
        output.sendDocuments()
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
        static let sizeUpperBound = 20
    }
}
