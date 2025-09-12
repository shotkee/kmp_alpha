//
//  QuestionnaireTableViewCell.swift
//  AlfaStrah
//
//  Created by Makson on 20.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class QuestionnaireTableViewCell: UITableViewCell {
    enum TypeCell {
        case needDoctor
        case yourAddress
        case callInformation
    }
    
    static let id: Reusable<QuestionnaireTableViewCell> = .fromClass()
    
    // MARK: - Outlets
    private var stackView = UIStackView()
    private var warningView = UIView()
    private var warningLabel = UILabel()
    private var shadowView = ShadowView()
    private var sectionsView = SectionsCardView(frame: .zero)
    private var descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    func setupUI() {
        selectionStyle = .none
        clipsToBounds = false
        contentView.clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        createStackView()
        createSectionsView()
        createDescriptionLabel()
        createWarningView()
    }
    
    func createStackView() {
        stackView.clipsToBounds = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 18, bottom: 9, right: 18)
        stackView.axis = .vertical
        stackView.spacing = 15
        contentView.addSubview(stackView)
        stackView.edgesToSuperview()
    }
    
    func createSectionsView() {
        shadowView.layer.cornerRadius = 12
        shadowView.shadowColor = Style.Color.Palette.lightGray
        shadowView.shadowOffset = CGSize(width: 0, height: 3)
        shadowView.shadowOpacity = 0.5
        shadowView.shadowRadius = 18
        shadowView.shadowCornerRadius = 12
        shadowView.backgroundColor = Style.Color.Palette.white
        stackView.addArrangedSubview(shadowView)
        shadowView.addSubview(sectionsView)
        sectionsView.edgesToSuperview()
    }
    
    func createDescriptionLabel() {
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.numberOfLines = 0
    }
    
    func createWarningView() {
		warningView.backgroundColor = .Background.backgroundTertiary
        warningView.clipsToBounds = true
        warningView.layer.cornerRadius = 10
        let iconImageView = UIImageView(
			image: .Icons.info.tintedImage(withColor: .Icons.iconAccent)
        )
        
        warningView.addSubview(iconImageView)
        iconImageView.height(18)
        iconImageView.width(18)
        iconImageView.topToSuperview(offset: 13)
        iconImageView.leadingToSuperview(offset: 12)
        
        warningLabel <~ Style.Label.primarySubhead
        warningLabel.numberOfLines = 0
        warningView.addSubview(warningLabel)
        warningLabel.topToSuperview(offset: 12)
        warningLabel.leadingToSuperview(offset: 39)
        warningLabel.trailingToSuperview(offset: 12)
        warningLabel.bottomToSuperview(offset: -12)
    }
}

extension QuestionnaireTableViewCell {
    func configure(
        items: [SectionsCardView.Item],
        warningText: String? = nil,
        description: String? = nil,
        typeCell: TypeCell
    ) {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        
        if typeCell == .callInformation {
            setupWarningLabel(
                text: warningText
            )
        }
        
        updateSectionsCardView(
            items: items
        )
        setupDescriptionLabel(
            description: description
        )
    }
    
    func updateSectionsCardView(items: [SectionsCardView.Item]) {
        sectionsView.updateItems(items)
        stackView.addArrangedSubview(sectionsView)
    }
    
    func setupWarningLabel(text: String?) {
        warningLabel.text = text
        if text != nil {
            stackView.addArrangedSubview(warningView)
        }
    }
    
    func setupDescriptionLabel(description: String?) {
        descriptionLabel.text = description
        if description != nil {
            stackView.addArrangedSubview(descriptionLabel)
        }
    }
}
