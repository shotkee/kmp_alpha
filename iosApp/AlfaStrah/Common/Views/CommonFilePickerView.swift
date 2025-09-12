//
//  CommonFilePickerView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 30.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class CommonFilePickerView: UIView {
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!

    var tapHandler: (() -> Void)?

    private var margins: UIEdgeInsets = .zero
    private var filesCount: Int = 0
    private var allFilesPresent: Bool = false

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
		backgroundColor = .Background.backgroundSecondary
        rootStackView.isLayoutMarginsRelativeArrangement = true

        titleLabel <~ Style.Label.primaryHeadline1
        titleLabel.text = NSLocalizedString("common_documents_title", comment: "")

        descriptionLabel <~ Style.Label.secondaryText

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

        updateUI()
    }

    private func updateUI() {
        rootStackView.layoutMargins = margins
        let format = NSLocalizedString("files_count", comment: "")
        descriptionLabel.text = String.localizedStringWithFormat(format, filesCount)
        iconView.image = allFilesPresent
			? .Icons.tick.tintedImage(withColor: .Icons.iconAccent)
			: .Icons.camera.tintedImage(withColor: .Icons.iconSecondary)
    }

    @objc private func viewTap() {
        tapHandler?()
    }

    func set(
        filesCount: Int,
        margins: UIEdgeInsets = .zero,
        allFilesPresent: Bool
    ) {
        self.filesCount = filesCount
        self.margins = margins
        self.allFilesPresent = allFilesPresent

        updateUI()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let image = iconView.image
		
		iconView.image = image?.tintedImage(withColor: allFilesPresent ? .Icons.iconAccent : .Icons.iconSecondary)
	}
}
