//
//  InsuranceProductLinkTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 24.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage
import TinyConstraints

// swiftlint:disable line_length file_length
class InsuranceProductTableViewCell: UITableViewCell,
                                         UICollectionViewDelegate,
                                         UICollectionViewDataSource,
                                         UICollectionViewDelegateFlowLayout
{
    // MARK: - Outlets
    private var shadowView = ShadowView()
    private var containerView = UIView()
    private var stackView = UIStackView()
    private var titleLabel = UILabel()
    private var descriptionContainerView = UIView()
    private var descriptionLabel = UILabel()
    private var pictureImageView = UIImageView()
    private var containerCollectionView = UIView()
    private var tagCollectionViewHeightConstraint: NSLayoutConstraint?
    private lazy var collectionView: UICollectionView = {
        let value: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
        value.backgroundColor = .clear
        value.delegate = self
        value.dataSource = self
        value.showsHorizontalScrollIndicator = false
        value.showsVerticalScrollIndicator = false
        value.isScrollEnabled = false
        value.isUserInteractionEnabled = false
        value.registerReusableCell(InsuranceProductTagCollectionViewCell.id)
        
        return value
    }()
    
    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let value: TagsLayout = .init()
        return value
    }()
    
    private var tagList: [InsuranceProductTag] = []
    
    static let id: Reusable<InsuranceProductTableViewCell> = .fromClass()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
    
    private func setupUI() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupContainerView()
        setupStackView()
        setupPictureImageView()
        setupTitleLabel()
        setupDescriptionLabel()
        setupCollectionView()
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = .Background.backgroundSecondary

        let cardView = containerView.embedded(
            margins: insets(v: 7, h: 18),
            hasShadow: true
        )
        
        contentView.addSubview(cardView)
        
        cardView.edges(to: contentView)
    }
        
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.layoutMargins = UIEdgeInsets(
            top: 15,
            left: 15,
            bottom: 15,
            right: 0
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -126),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: 0)
        ])
    }
    
    private func setupPictureImageView() {
        pictureImageView.backgroundColor = .clear
        pictureImageView.contentMode = .scaleAspectFill
        pictureImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pictureImageView)
        NSLayoutConstraint.activate([
            pictureImageView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 0),
            pictureImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pictureImageView.leadingAnchor.constraint(equalTo: stackView.trailingAnchor),
            pictureImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pictureImageView.heightAnchor.constraint(equalToConstant: 126),
            pictureImageView.widthAnchor.constraint(equalToConstant: 126)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel <~ Style.Label.primaryHeadline3
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupCollectionView() {
        stackView.setCustomSpacing(12, after: descriptionLabel)
        stackView.addArrangedSubview(containerCollectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerCollectionView.addSubview(collectionView)
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: Constants.tagViewHeight)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: containerCollectionView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerCollectionView.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerCollectionView.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerCollectionView.bottomAnchor),
            heightConstraint
        ])
        tagCollectionViewHeightConstraint = heightConstraint
    }
    
    func configure(
        insuranceProduct: InsuranceProduct
    ) {
        setTitleLabel(text: insuranceProduct.title)
        setDescriptionLabel(text: insuranceProduct.text)
        setPictureImage(imageUrl: insuranceProduct.image)
        self.tagList = insuranceProduct.tagList
        self.containerCollectionView.isHidden = insuranceProduct.tagList.isEmpty
        tagCollectionViewHeightConstraint?.constant = getHeightCollectionView()
        collectionView.reloadData()
    }
    
    private func getHeightCollectionView() -> CGFloat {
		var height: CGFloat = Constants.tagViewHeight
		var collectionViewWidth = Constants.defaultWidthCollection
        let spaceBetweenSection: CGFloat = 6
        let spaceBetweenCell = spaceBetweenSection
        var countSection: Int = 1
        
        tagList.forEach { tag in
            let widthTag = tag.title.width(
                withConstrainedHeight: 15,
                font: Style.Font.text
            )
            
            let remainderWidthCell = collectionViewWidth - (spaceBetweenCell * CGFloat(countSection)) - widthTag
            
            if remainderWidthCell > 0 {
                collectionViewWidth = remainderWidthCell
                countSection += 1
            }
            else {
                countSection = countSection == 1 ? countSection + 1 : countSection
                height += Constants.tagViewHeight + spaceBetweenSection
				collectionViewWidth = Constants.defaultWidthCollection - widthTag - (spaceBetweenCell * CGFloat(countSection))
                countSection = 1
            }
        }
        
        return height
    }
    
    private func setTitleLabel(
        text: String
    ) {
        titleLabel.text = text
    }
    
    private func setDescriptionLabel(
        text: String
    ) {
        descriptionLabel.text = text
    }
    
    private func setPictureImage(
        imageUrl: URL
    ) {
        pictureImageView.sd_setImage(
            with: imageUrl
        )
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tagList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            InsuranceProductTagCollectionViewCell.id,
            indexPath: indexPath
        )
		
        cell.configure(
            insuranceProductTag: tagList[indexPath.item],
			maxWidth: Constants.defaultWidthCollection
        )
        
        return cell
    }
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		collectionView.reloadData()
	}
	
	struct Constants {
		static let tagViewHeight: CGFloat = 24
		static let pictureImageWidth: CGFloat = 126
		static let leftAndRightPadding: CGFloat = 30
		static let widthScreen = UIScreen.main.bounds.width
		static let defaultWidthCollection: CGFloat = widthScreen - 36 - pictureImageWidth - leftAndRightPadding
	}
}
