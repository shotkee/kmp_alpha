//
//  PhotoCardCollectionViewCell.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 04.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class PhotoCardCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let cornerRadius: CGFloat = 12
        static let expandedBoundsInsets = UIEdgeInsets(top: -12, left: 0, bottom: 0, right: -12)
    }

    static let id: Reusable<PhotoCardCollectionViewCell> = .fromNib()

    enum State {
        case photo(UIImage)
        case empty(icon: UIImage)
    }

    @IBOutlet private var photoCardImage: UIImageView!
    @IBOutlet private var deleteButton: UIButton!
    @IBOutlet private var photoCardView: PhotoCardView!

    var deleteHandler: (() -> Void)?

    override open var isHighlighted: Bool {
        didSet {
            updateHighlightedStateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        configureShadow()
    }

    private func setupUI() {
        updateHighlightedStateUI()

        deleteButton.layer.cornerRadius = Constants.cornerRadius
        photoCardView.layer.cornerRadius = Constants.cornerRadius
        photoCardImage.layer.cornerRadius = Constants.cornerRadius
    }

    func configure(with state: State) {
        switch state {
            case .photo(let image):
                photoCardImage.image = image
                photoCardImage.contentMode = .scaleAspectFill
                deleteButton.isHidden = false
            case .empty(let icon):
                photoCardImage.image = icon
                photoCardImage.contentMode = .center
                deleteButton.isHidden = true
        }
    }

    private func updateHighlightedStateUI() {
		let highlightedColor: UIColor = .Background.backgroundSecondary.withAlphaComponent(0.2)
		photoCardView.backgroundColor = isHighlighted ? highlightedColor : .Background.backgroundSecondary
    }

    private func configureShadow() {
        deleteButton.layer.shadowPath = UIBezierPath(ovalIn: deleteButton.bounds).cgPath
		deleteButton.layer <~ ShadowAppearance.buttonShadow
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let adjustedRect = bounds.inset(by: Constants.expandedBoundsInsets)
        return adjustedRect.contains(point)
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        deleteHandler?()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		deleteButton.layer <~ ShadowAppearance.buttonShadow
	}
}
