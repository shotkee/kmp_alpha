//
//  CommonDocumentsUploadInfoView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class CommonDocumentsUploadInfoView: UIView {
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!

    private var margins: UIEdgeInsets = .zero
    private var uploadedFilesCount: Int = 0
    private var totalFilesCount: Int = 0

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        addSelfAsSubviewFromNib()
        setup()
    }

    private func setup() {
        rootStackView.isLayoutMarginsRelativeArrangement = true

        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("common_documents_title", comment: "")

        descriptionLabel <~ Style.Label.secondaryText
        updateUI()
    }

    private func updateUI() {
        rootStackView.layoutMargins = margins
        let uploadedFilesFormat = NSLocalizedString("files_count", comment: "")
        let uploadedFilesText = String.localizedStringWithFormat(uploadedFilesFormat, uploadedFilesCount)

        descriptionLabel.text = String(
            format: NSLocalizedString("accident_event_photos_upload_progress_value", comment: ""),
            uploadedFilesText, "\(totalFilesCount)"
        )
    }

    func set(margins: UIEdgeInsets) {
        self.margins = margins
        updateUI()
    }

    func set(uploadedFilesCount: Int, totalFilesCount: Int) {
        self.uploadedFilesCount = uploadedFilesCount
        self.totalFilesCount = totalFilesCount
        updateUI()
    }
}
