//
//  SosInfoView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class SosInfoView: UIView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!

    var tapCallback: (() -> Void)?

    enum Mode {
        case header
        case info
    }
	
	private var isActive: Bool = false {
		didSet {
			updateIconColor()
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

        descriptionLabel <~ Style.Label.secondaryText
    }
	
	private var icon: UIImage?
	private var overlay: UIImage?

    func set(
        mode: Mode,
        title: String,
        description: String,
        icon: UIImage?,
		overlay: UIImage? = nil,
        isActive: Bool,
        tapCallback: @escaping () -> Void
    ) {
        switch mode {
            case .header:
                titleLabel <~ Style.Label.primaryHeadline1
            case .info:
                titleLabel <~ Style.Label.primaryHeadline1
        }
		self.icon = icon
		self.overlay = overlay
        titleLabel.text = title
        descriptionLabel.text = description
		iconImageView.image = icon
		
		self.isActive = isActive
		
        self.tapCallback = tapCallback
    }

    @objc private func viewTap() {
        tapCallback?()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateIconColor()
	}
	
	private func updateIconColor() {

		let iconColor: UIColor = isActive ? .Icons.iconAccent : .Icons.iconSecondary
		iconImageView.image = icon?.tintedImage(withColor: iconColor).overlay(with: overlay ?? UIImage())
	}
}
