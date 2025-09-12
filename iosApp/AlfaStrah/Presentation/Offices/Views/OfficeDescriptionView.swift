//
//  OfficeDescriptionView.swift
//  AlfaStrah
//
//  Created by mac on 06.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

final class OfficeDescriptionView: UIView {
    // Constants
    private enum Constants {
        static let defaultInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        static let rootToHeaderStackViewSpacing: CGFloat = 9
        static let addressStackViewSpacing: CGFloat = 8
        static let iconImageSize: CGSize = .init(width: 20, height: 20)
    }

    private enum Styles {
        static let titleLabelStyle = Style.Label.primaryHeadline1
        static let descriptionLabelStyle = Style.Label.primaryText
    }
    
    // Use for store reference text blocks and handle taps
    private var textBlocks: [CommonInfoView.TextBlock] = []

    // Views
    private lazy var iconImageView: UIImageView = {
        let imageView: UIImageView = .init(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()

    // Stacks
    private lazy var rootStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.backgroundColor = .Background.backgroundContent
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = Constants.rootToHeaderStackViewSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = Constants.defaultInsets
        return stack
    }()

    private lazy var headerStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = Constants.addressStackViewSpacing
        return stack
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        return stack
    }()

    // Labels
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    // MARK: Builders

    private func setupUI() {
        clipsToBounds = false
        backgroundColor = .clear

        addSubview(rootStackView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: self)
        )
        setupRootStack()

        titleLabel <~ Styles.titleLabelStyle
    }

    private func setupRootStack() {
        rootStackView.addArrangedSubview(headerStackView)
        setupHeaderView()
    }

    private func setupHeaderView() {
        descriptionStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(iconImageView)
        headerStackView.addArrangedSubview(descriptionStackView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconImageSize.height),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconImageSize.width),
        ])
    }

    // MARK: Методы
    
    private func descriptionLabel() -> UILabel {
        let label = UILabel()
        label <~ Styles.descriptionLabelStyle
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }
        
    func set(
        title: String?,
        blocks: [CommonInfoView.TextBlock],
        icon: UIImage?,
        textStyle: Style.Label.ColoredLabel? = nil
    ) {
        for textCell in blocks {
            textBlocks = blocks
            let label = descriptionLabel()
            if let textStyle {
                label <~ textStyle
            }
            label.text = textCell.text
            let tapGestureRecognizer = UITapGestureRecognizer(target: textCell, action: #selector(textCell.textTap))
            label.addGestureRecognizer(tapGestureRecognizer)
            descriptionStackView.addArrangedSubview(label)
        }
        titleLabel.text = title
        iconImageView.image = icon
    }

    func set(
        title: String?,
        description: String,
        icon: UIImage?
    ) {
        let label = descriptionLabel()
        label.text = description
        descriptionStackView.addArrangedSubview(label)
        titleLabel.text = title
        iconImageView.image = icon
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    
        guard let image = iconImageView.image
        else { return }
        
        iconImageView.image = image.tintedImage(withColor: .Icons.iconSecondary)
    }
}
