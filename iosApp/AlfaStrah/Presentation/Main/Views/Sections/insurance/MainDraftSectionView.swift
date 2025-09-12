//
//  MainDraftSectionView.swift
//  AlfaStrah
//
//  Created by mac on 17.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class MainDraftSectionView: UIView {
	private let imageView = UIImageView()
	private let arrowImageView = UIImageView()
	
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    struct Input {
        var tapOnView: () -> Void
    }
    
    var input: Input!
    
    @objc private func touchSection() {
        input.tapOnView()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchSection))
        addGestureRecognizer(tapGestureRecognizer)
        
        let whiteBackground = UIView()
        whiteBackground.backgroundColor = .Background.backgroundSecondary
        
        let rootStackView = UIStackView()
        rootStackView.distribution = .fill
        rootStackView.alignment = .center
        rootStackView.axis = .horizontal
        rootStackView.spacing = 9
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        
        whiteBackground.addSubview(rootStackView)
        
		imageView.image = .Icons.listPen2.tintedImage(withColor: .Icons.iconTertiary)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.text = NSLocalizedString("main_drafts_calculation_title", comment: "")
        titleLabel <~ Style.Label.primaryHeadline2
        
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = NSLocalizedString("main_drafts_calculation_description", comment: "")
        descriptionLabel <~ Style.Label.secondaryCaption1

        let labelsStackView = UIStackView()
        labelsStackView.distribution = .fill
        labelsStackView.alignment = .fill
        labelsStackView.axis = .vertical
        
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(descriptionLabel)
        
		arrowImageView.image = .Icons.arrow.tintedImage(withColor: .Icons.iconSecondary)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false

        rootStackView.addArrangedSubview(imageView)
        rootStackView.addArrangedSubview(labelsStackView)
        rootStackView.addArrangedSubview(arrowImageView)
        
        let cardView = CardView(contentView: whiteBackground)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.isUserInteractionEnabled = false
        self.addSubview(cardView)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: rootStackView,
                in: whiteBackground,
                margins: .init(top: 15, left: 15, bottom: 15, right: 15)
            ) +
            NSLayoutConstraint.fill(view: cardView, in: self)
            + [
                imageView.widthAnchor.constraint(equalToConstant: 24),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                arrowImageView.widthAnchor.constraint(equalToConstant: 24),
                arrowImageView.heightAnchor.constraint(equalTo: arrowImageView.widthAnchor)
            ]
        )
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		let image = imageView.image
		imageView.image = image?.tintedImage(withColor: .Icons.iconTertiary)
		
		let arrowImage = arrowImageView.image
		arrowImageView.image = arrowImage?.tintedImage(withColor: .Icons.iconSecondary)
	}
}
