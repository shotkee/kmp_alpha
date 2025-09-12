//
//  InsuranceCategoryView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 01/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import SDWebImage

class InsuranceCategoryView: UIView {
    @IBOutlet private var typeImageView: UIImageView!
    @IBOutlet private var typeTitle: UILabel!
    @IBOutlet private var containerStackView: UIStackView!
    @IBOutlet private var topOffsetConstraint: NSLayoutConstraint!
	private var imageThemed: ThemedValue?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }
	
	func updateColors(theme: UIUserInterfaceStyle) {
		guard let imageThemed
		else { return }
		let imageThemedURL = imageThemed.url(for: theme)

		typeImageView.sd_setImage(
			with: imageThemedURL,
			placeholderImage: nil
		)
	}

	func set(title: String, image: UIImage?, imageThemed: ThemedValue?, isFirst: Bool, childs: [UIView]) {
        childs.forEach(containerStackView.addArrangedSubview)
		self.imageThemed = imageThemed
		if let imageThemed {
			updateColors(theme: traitCollection.userInterfaceStyle)
		} else {
			typeImageView.image = image?.tintedImage(withColor: .Icons.iconTertiary)
		}
        typeTitle.text = title
        topOffsetConstraint.constant = isFirst ? 3 : 18
    }

    private func setupStyle() {
        typeTitle <~ Style.Label.primaryCaption1
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let image = typeImageView.image?.tintedImage(withColor: .Icons.iconTertiary)
        
        typeImageView.image = image
    }
}
