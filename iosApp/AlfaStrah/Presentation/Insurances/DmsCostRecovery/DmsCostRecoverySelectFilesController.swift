//
//  DmsCostRecoverySelectFilesController.swift
//  AlfaStrah
//
//  Created by vit on 01.02.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoverySelectFilesController: ViewController, AttachmentServiceDependency {
    var attachmentService: AttachmentService!
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    
    private let nextButton = RoundEdgeButton()
    
    struct Notify {
        var update: (DmsCostRecoveryDocument, [Attachment]) -> Void
        var isNextButtonEnabled: (_ enabled: Bool) -> Void
    }
    
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        update: { [weak self] file, attachments in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(for: file, with: attachments)
        },
        isNextButtonEnabled: { [weak self] enabled in
            self?.nextButton.isEnabled = enabled
        }
    )
    
    struct Upload {
        let uploadName: String
        let attachment: Attachment
    }
        
    struct Input {
        let documentsList: DmsCostRecoveryDocumentsList
        let getDocumentUploads: () -> [Upload]
        let nextButtonEnabled: () -> Bool
    }
    
    var input: Input!
    
    struct Output {
        let addFile: (DmsCostRecoveryDocument) -> Void
        let nextButtonTap: () -> Void
    }
    
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		view.backgroundColor = .Background.backgroundContent
        title = input.documentsList.shortTitle
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        addCards()
        
        setupNextButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for file in input.documentsList.documents {
            let attachments = input.getDocumentUploads().compactMap { $0.uploadName == file.uploadName ? $0.attachment : nil }
            if !attachments.isEmpty {
                self.update(for: file, with: attachments)
            }
        }
        
        nextButton.isEnabled = input.nextButtonEnabled()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.contentInset.bottom != actionButtonsStackView.bounds.height {
            scrollView.contentInset.bottom = actionButtonsStackView.bounds.height
        }
    }
    
    private func addCards() {
        for document in input.documentsList.documents {
            let view = TitledValueCardView()
            view.set(
                attributedTitle: NSMutableAttributedString(string: document.title) <~ Style.TextAttributes.grayInfoText,
                subTitle: NSLocalizedString("dms_cost_recovery_upload_recovery_attach_documents", comment: ""),
                placeholder: NSLocalizedString("dms_cost_recovery_upload_recovery_no_files", comment: ""),
                icon: .photo,
                isRequiredField: document.isRequired
            )
            
            view.tapHandler = { [weak self] in
                self?.output.addFile(document)
            }
            
            contentStackView.addArrangedSubview(view)
        }
    }
    
    private func setupNextButton() {
        nextButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        nextButton.setTitle(
            NSLocalizedString("common_continue", comment: ""),
            for: .normal
        )
        nextButton.addTarget(self, action: #selector(nextButtonTap), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(nextButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
        
        nextButton.isEnabled = false
    }
    
    private func update(for file: DmsCostRecoveryDocument, with attachments: [Attachment]) {
        guard let fileIndex = input.documentsList.documents.firstIndex(where: { $0 == file }),
              let view = contentStackView.subviews[fileIndex] as? TitledValueCardView
        else { return }
        
        if attachments.isEmpty {
            view.set(
                attributedTitle: NSMutableAttributedString(string: file.title) <~ Style.TextAttributes.grayInfoText,
                subTitle: NSLocalizedString("dms_cost_recovery_upload_recovery_attach_documents", comment: ""),
                attributedSubtitle: nil,
                placeholder: NSLocalizedString("dms_cost_recovery_upload_recovery_no_files", comment: ""),
                icon: .photo,
                isRequiredField: file.isRequired
            )
            
            view.tapHandler = { [weak self] in
                self?.output.addFile(file)
            }
            
            return
        }
        
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
    
    private func bytesCountFormatted(from bytesCount: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytesCount)
    }
    
    @objc func nextButtonTap(_ sender: UIButton) {
        output.nextButtonTap()
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
