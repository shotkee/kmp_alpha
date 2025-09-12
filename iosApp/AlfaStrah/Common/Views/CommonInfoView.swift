//
//  CommonInfoView.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class CommonInfoView: UIView {
    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var textsStackView: UIStackView!
    @IBOutlet private var separatorView: HairLineView!

    private var appearance: Appearance = .regular
    private var title: String?
    private var text: String = ""
    private var icon: UIImage?

    struct Appearance {
        let margins: UIEdgeInsets
        let titleStyle: Style.Label.ColoredLabel
        let textBlockStyle: Style.Label.ColoredLabel
        let separator: Bool

        private enum Constants {
            static let defaultInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            static let defaultTitleStyle = Style.Label.secondaryText
            static let defaultTextBlockStyle = Style.Label.primaryHeadline1
            static let defaultLinkTextBlockStyle = Style.Label.accentHeadline1
            static let bodyLinkTextBlockStyle = Style.Label.accentText
            static let newTitleStyle = Style.Label.secondaryCaption1
            static let newTextBlockStyle = Style.Label.primaryText
            static let mediumTitleStyle = Style.Label.primaryHeadline2
        }

        init(
            margins: UIEdgeInsets = Constants.defaultInsets,
            titleStyle: Style.Label.ColoredLabel = Constants.defaultTitleStyle,
            textBlockStyle: Style.Label.ColoredLabel = Constants.defaultTextBlockStyle,
            separator: Bool
        ) {
            self.margins = margins
            self.titleStyle = titleStyle
            self.textBlockStyle = textBlockStyle
            self.separator = separator
        }

        static let regular = Appearance(separator: true)
        static let regularLink = Appearance(textBlockStyle: Constants.defaultLinkTextBlockStyle, separator: true)
        static let newRegularLinkWithoutSeparator = Appearance(
            textBlockStyle: Constants.bodyLinkTextBlockStyle,
            separator: false
        )
        static let linkSmallTitleWithoutSeparator = Appearance(
            titleStyle: Constants.newTitleStyle,
            textBlockStyle: Constants.bodyLinkTextBlockStyle,
            separator: false
        )
        static let newRegular = Appearance(
            titleStyle: Constants.newTitleStyle,
            textBlockStyle: Constants.newTextBlockStyle,
            separator: true
        )
        static let newRegularWithoutSeparator = Appearance(
            titleStyle: Constants.newTitleStyle,
            textBlockStyle: Constants.newTextBlockStyle,
            separator: false

        )
        static let newMediumWithoutSeparator = Appearance(
            titleStyle: Constants.newTitleStyle,
            textBlockStyle: Constants.mediumTitleStyle,
            separator: false

        )
        static let cell = Appearance(margins: .zero, separator: false)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)
        rootStackView.isLayoutMarginsRelativeArrangement = true

        updateUI()
    }

    private func updateUI() {
        iconView.image = icon
        iconView.isHidden = icon == nil

        rootStackView.layoutMargins = appearance.margins
        separatorView.isHidden = !appearance.separator
		separatorView.lineColor = .Stroke.divider

        textsStackView.subviews.forEach { $0.removeFromSuperview() }
        if let title = title {
            let label = titleLabel()
            label.text = title
            textsStackView.addArrangedSubview(label)
        }

        for textCell in textBlocks {
            let label = textLabel()
            label.text = textCell.text
            let tapGestureRecognizer = UITapGestureRecognizer(target: textCell, action: #selector(textCell.textTap))
            label.addGestureRecognizer(tapGestureRecognizer)
            textsStackView.addArrangedSubview(label)
        }
    }

    private func titleLabel() -> UILabel {
        let label = UILabel()
        label <~ appearance.titleStyle
        return label
    }

    private func textLabel() -> UILabel {
        let label = UILabel()
        label <~ appearance.textBlockStyle
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }

    private var textBlocks: [TextBlock] = []

    class TextBlock {
        let text: String
        var tapCallback: (() -> Void)?

        init(text: String, tapCallback: (() -> Void)? = nil) {
            self.text = text
            self.tapCallback = tapCallback
        }

        @objc func textTap() {
            tapCallback?()
        }
    }

    func set(
        title: String?,
        textBlocks: [TextBlock],
        icon: UIImage? = nil,
        appearance: Appearance = .regular
    ) {
        self.title = title
        self.textBlocks = textBlocks
		self.icon = icon?.tintedImage(withColor: .Icons.iconAccent)
        self.appearance = appearance

        updateUI()
    }

    @objc private func viewTap() {
        if textBlocks.count == 1 {
            textBlocks.first?.textTap()
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		let iconImage = iconView.image
		
		iconView.image = iconImage?.tintedImage(withColor: .Icons.iconAccent)
	}
}
