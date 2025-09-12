//
//  AddPhotoStepView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class AddPhotoStepView: UIView {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var textsStackView: UIStackView!

    private var title: String = ""
    private var text: String = ""
    private var image: UIImage?
    private var tapHandler: (() -> Void)?

    static let margins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 12)

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
		backgroundColor = .Background.backgroundSecondary
		
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)
        rootStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.layoutMargins = AddPhotoStepView.margins
		imageView.backgroundColor = .Background.backgroundTertiary
        updateUI()
    }

    private func updateUI() {
		updateImage()

        textsStackView.subviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.font = Style.Font.text
		titleLabel.textColor = .Text.textSecondary
        titleLabel.text = title
        textsStackView.addArrangedSubview(titleLabel)

        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.font = Style.Font.headline1
		textLabel.textColor = .Text.textPrimary
        textLabel.text = text
        textsStackView.addArrangedSubview(textLabel)
    }
	
	func updateImage() {
		if let image {
			imageView.image = image
			imageView.contentMode = .scaleAspectFill
		} else {
			imageView.image = .Icons.camera.tintedImage(withColor: .Icons.iconSecondary)
			imageView.contentMode = .center
		}
	}
	
    func set(title: String, text: String, image: UIImage?, tapHandler: @escaping () -> Void) {
        self.title = title
        self.text = text
        self.image = image
        self.tapHandler = tapHandler
        updateUI()
    }

    @objc private func viewTap() {
        tapHandler?()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		updateImage()
	}
}
