//
//  AttachmentUploadViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class AttachmentUploadViewController: ViewController,
									  AttachmentServiceDependency {
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var attentionLabel: UILabel!
    @IBOutlet private var tipLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var button: RoundEdgeButton!

    var attachmentService: AttachmentService!

    struct Input {
        var eventReportId: String
        var text: String
        var attentionText: String?
        var presentationMode: ViewControllerShowMode
    }

    struct Output {
        var close: () -> Void
        var doneAction: (() -> Void)?
    }

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        subscribeToUploads()
        updateUI()

        applicationActive.subscribe { [weak self] _ in
            self?.updateUI()
        }.disposed(by: disposeBag)
    }

    // MARK: - Setup UI

    private func setupUI() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("common_pick_documents", comment: "")
        
        statusLabel <~ Style.Label.primaryHeadline1
        
        tipLabel <~ Style.Label.primaryText
        tipLabel.text = input.text
        
        attentionLabel <~ Style.Label.accentText
        attentionLabel.text = input.attentionText

        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        button.setTitle(NSLocalizedString("common_done_button", comment: ""), for: .normal)
        let image: UIImage?
        switch input.presentationMode {
            case .modal:
                image = UIImage(named: "ico-upload-in-progress")
                button.isHidden = true
                addCloseButton { [weak self] in
                    self?.output.close()
                }
            case .push:
                image = UIImage(named: "ico-upload-completed")
                button.isHidden = false
                button.addTarget(self, action: #selector(showReportTap(_:)), for: .touchUpInside)
        }
        imageView.image = image
        navigationItem.hidesBackButton = true
    }

    private func updateUI() {
        if let status = attachmentService.uploadStatus(eventReportId: input.eventReportId) {
            statusLabel.text = String(
                format: NSLocalizedString("documents_upload_status_value", comment: ""),
                "\(status.uploadedDocumentsCount)", "\(status.totalDocumentsCount)"
            )
            imageView.image = UIImage(named: status.finished ? "ico-upload-completed" : "ico-upload-in-progress")
        } else {
            imageView.image = UIImage(named: "ico-upload-completed")
            statusLabel.text = NSLocalizedString("zero_photos_upload_success_message", comment: "")
        }
    }

    private func subscribeToUploads() {
        attachmentService.subscribeToUploads { [weak self] in
            self?.updateUI()
        }.disposed(by: disposeBag)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: NSLocalizedString("common_ok_button", comment: ""), style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    @objc private func showReportTap(_ sender: UIButton) {
        output.doneAction?()
    }
}
