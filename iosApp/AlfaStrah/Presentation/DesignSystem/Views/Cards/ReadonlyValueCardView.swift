//
//  ReadonlyValueCardView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

/// Карточки, показывающие в какой раздел пользователь может перейти
class ReadonlyValueCardView: UIView {
    struct Appearance {
        let titleStyle: Style.Label.ColoredLabel
        let valueStyle: Style.Label.ColoredLabel

        static let regular: Appearance = Appearance(
            titleStyle: Style.Label.secondaryText,
            valueStyle: Style.Label.primaryHeadline3
        )
    }

    private let rootStackView: UIStackView = .init()
    private let titleLabel: UILabel = .init()
    private let valueLabel: UILabel = .init()
    private let iconImageView: UIImageView = .init()

    private var icon: UIImage?
    private var appearance: Appearance = .regular
    private var margins: UIEdgeInsets = .zero
    private var title: String = ""
    private var value: String = ""

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        updateUI()
        backgroundColor = Style.Color.Palette.white
        addSubview(rootStackView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: self) +
            [
                iconImageView.heightAnchor.constraint(equalToConstant: 24),
                iconImageView.widthAnchor.constraint(equalToConstant: 24),
            ]
        )

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

        titleLabel.numberOfLines = 1
        valueLabel.numberOfLines = 2

        rootStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.axis = .horizontal
        rootStackView.alignment = .top
        rootStackView.distribution = .fill
        rootStackView.spacing = 9

        let verticalStack: UIStackView = .init()
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.distribution = .fill
        verticalStack.spacing = 0

        rootStackView.addArrangedSubview(verticalStack)
        rootStackView.addArrangedSubview(iconImageView)
        verticalStack.addArrangedSubview(titleLabel)
        verticalStack.addArrangedSubview(valueLabel)

        verticalStack.setCustomSpacing(6, after: titleLabel)
    }

    private func updateUI() {
        rootStackView.layoutMargins = margins

        iconImageView.image = icon
        titleLabel.text = title
        valueLabel.text = value

        iconImageView.isHidden = icon == nil
        titleLabel.isHidden = title.isEmpty
        valueLabel.isHidden = value.isEmpty

        titleLabel <~ appearance.titleStyle
        valueLabel <~ appearance.valueStyle
    }

    func set(
        title: String,
        value: String,
        icon: UIImage? = UIImage(named: "right_arrow_icon_gray"),
        margins: UIEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15),
        appearance: Appearance = .regular
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.margins = margins
        self.appearance = appearance

        updateUI()
    }

    var tapHandler: (() -> Void)?

    @objc private func viewTap() {
        tapHandler?()
    }
}
