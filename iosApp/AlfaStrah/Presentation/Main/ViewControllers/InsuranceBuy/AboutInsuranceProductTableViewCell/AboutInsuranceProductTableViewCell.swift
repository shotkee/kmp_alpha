//
//  AboutInsuranceProductTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 26.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage

class AboutInsuranceProductTableViewCell: UITableViewCell {
    static let id: Reusable<AboutInsuranceProductTableViewCell> = .fromClass()
    
    // MARK: - Outlets
    private var contentStackView = UIStackView()
    private var pictureImageView = UIImageView()
    private var titleContainerView = UIView()
    private var titleLabel = UILabel()
    private var linkTextContainerView = UIView()
    private var linkTextView = LinkedTextView()
    private var shadowContainerView = UIView()
    private var cardView = CardView()
    private var checkStackView = UIStackView()
    private var contentImageView = UIImageView()
	private let gradientOverlayImageView = UIImageView()
	
    var openUrl: ((URL) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
    
    private func setupUI() {
		selectionStyle = .none
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
        setupPictureImage()
        setupContentStackView()
        setupTextLabel()
        setupLinkTextView()
        setupCheckMarkText()
        setupCheckStackView()
    }
	
	private func updateGradientOverlay() {
		gradientOverlayImageView.image = UIImage.gradientImage(
			from: .Other.imageGradient.withAlphaComponent(0),
			to: .Other.imageGradient,
			with: gradientOverlayImageView.frame
		)
	}
    
    private func setupPictureImage() {
        pictureImageView.translatesAutoresizingMaskIntoConstraints = false
        pictureImageView.contentMode = .scaleAspectFill
        contentView.addSubview(pictureImageView)
		pictureImageView.addSubview(gradientOverlayImageView)
		gradientOverlayImageView.edgesToSuperview(excluding: .top)
		gradientOverlayImageView.height(Constants.imageGradientOverlayHeight)
		updateGradientOverlay()
        
        NSLayoutConstraint.activate([
            pictureImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pictureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pictureImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pictureImageView.heightAnchor.constraint(equalTo: pictureImageView.widthAnchor, multiplier: 230 / 375)
        ])
    }
    
    private func setupContentStackView() {
        contentStackView.axis = .vertical
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: pictureImageView.bottomAnchor, constant: 21),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -21)
        ])
    }
    
    private func setupTextLabel() {
        titleLabel <~ Style.Label.primaryTitle1
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleContainerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor)
        ])
    }
    
    private func setupLinkTextView() {
        linkTextView.textContainerInset = .zero
        linkTextView.textAlignment = .left
        linkTextView.translatesAutoresizingMaskIntoConstraints = false
        linkTextContainerView.addSubview(linkTextView)
        
        NSLayoutConstraint.activate([
            linkTextView.topAnchor.constraint(equalTo: linkTextContainerView.topAnchor),
            linkTextView.leadingAnchor.constraint(equalTo: linkTextContainerView.leadingAnchor, constant: 15),
            linkTextView.trailingAnchor.constraint(equalTo: linkTextContainerView.trailingAnchor, constant: -15),
            linkTextView.bottomAnchor.constraint(equalTo: linkTextContainerView.bottomAnchor)
        ])
    }
    
    private func setupCheckMarkText() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        shadowContainerView.addSubview(cardView)
		
		cardView.cornerRadius = 12
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor, constant: 15),
            cardView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor, constant: -15),
            cardView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor)
        ])
    }
    
    private func setupCheckStackView() {
        checkStackView.axis = .vertical
        checkStackView.spacing = 15

		cardView.set(content: checkStackView)
		cardView.isUserInteractionEnabled = false
		
		checkStackView.backgroundColor = .Background.backgroundSecondary
        		
		checkStackView.layoutMargins = insets(15)
		checkStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    private func setSizeContentImageView() {
        contentImageView.backgroundColor = .clear
        contentImageView.heightAnchor.constraint(equalTo: pictureImageView.heightAnchor, multiplier: 1).isActive = true
        contentImageView.widthAnchor.constraint(equalTo: pictureImageView.widthAnchor, multiplier: 1).isActive = true
    }
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateGradientOverlay()
	}
}

extension AboutInsuranceProductTableViewCell {
    func configure(
        insuranceProduct: InsuranceProduct
    ) {
        setPictureImage(
            imageUrl: insuranceProduct.detailedImage
        )
        contentStackView.subviews.forEach { $0.removeFromSuperview() }
        insuranceProduct.detailedContent.forEach { content in
            switch content.contentType {
                case .title:
                    setTitleLabel(text: content.data.text)
                case .linkedText:
                    setLinkedText(linkedText: content.data.linkedText)
                case .listWithCheckmark:
                    setCheckMark(checkMarks: content.data.textArray)
                case .image:
                    setContentImage(imageUrl: content.data.image)
            }
        }
    }
    
    func setPictureImage(imageUrl: URL) {
        pictureImageView.sd_setImage(
            with: imageUrl
        )
    }
    
    func setTitleLabel(text: String?) {
        guard let text = text,
              !text.isEmpty
        else { return }
        
        contentStackView.addArrangedSubview(titleContainerView)
        contentStackView.setCustomSpacing(9, after: titleContainerView)
        titleLabel.text = text
    }
    
    func setLinkedText(
        linkedText: LinkedText?
    ) {
        guard let linkedText = linkedText
        else { return }
        
        contentStackView.addArrangedSubview(linkTextContainerView)
        contentStackView.setCustomSpacing(18, after: linkTextContainerView)
        
        linkTextView.set(
            text: linkedText.text,
            links: linkedText.links.map {
                .init(
                    text: $0.text,
                    link: URL(string: "https://" + $0.path),
                    tapHandler: { [weak self] url in
                        guard let self = self,
                              let url = url
                        else { return }
                        
                        self.openUrl?(url)
                    }
                )
            },
            textAttributes: Style.TextAttributes.normalText,
			linkColor: .Text.textAccent,
            isUnderlined: false
        )
    }
    
    func setCheckMark(checkMarks: [String]?) {
        guard let checkMarks = checkMarks,
              !checkMarks.isEmpty
        else { return }
        
        contentStackView.addArrangedSubview(shadowContainerView)
        contentStackView.setCustomSpacing(21, after: shadowContainerView)
        
		checkStackView.subviews.forEach { $0.removeFromSuperview() }
		
        for checkMark in checkMarks {
            checkStackView.addArrangedSubview(
                createCheckMarkView(
                    text: checkMark
                )
            )
        }
    }
    
    func createCheckMarkView(text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let checkImage = UIImageView(
			image: .Icons.tick.tintedImage(withColor: .Icons.iconAccent)
        )
        
        checkImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(checkImage)
        NSLayoutConstraint.activate([
            checkImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 1),
            checkImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            checkImage.heightAnchor.constraint(equalToConstant: 16),
            checkImage.widthAnchor.constraint(equalTo: checkImage.heightAnchor, multiplier: 1)
        ])
        
        let textLabel = UILabel()
        textLabel <~ Style.Label.primaryText
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .left
        textLabel.text = text
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: checkImage.trailingAnchor, constant: 9),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    private func setContentImage(imageUrl: URL?) {
        guard let imageUrl = imageUrl
        else { return }
        
        contentStackView.addArrangedSubview(contentImageView)
        contentImageView.sd_setImage(
            with: imageUrl
        )
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        setSizeContentImageView()
    }
	
	struct Constants {
		static let imageGradientOverlayHeight: CGFloat = 87
	}
}
