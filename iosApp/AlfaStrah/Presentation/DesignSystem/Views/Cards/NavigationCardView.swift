//
//  NavigationCardView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

/// Карточки, показывающие в какой раздел пользователь может перейти
class NavigationCardView: HighlightableCardView {
    struct Appearance {
        let titleStyle: Style.Label.ColoredLabel
        let subtitleStyle: Style.Label.ColoredLabel
    }

    struct StateAppearance {
        let enabled: Appearance
        let disabled: Appearance

        static let regular: StateAppearance = StateAppearance(
            enabled: Appearance(
                titleStyle: Style.Label.primaryHeadline2,
                subtitleStyle: Style.Label.secondaryText
            ),
            disabled: Appearance(
                titleStyle: Style.Label.secondaryHeadline2,
                subtitleStyle: Style.Label.secondaryText
            )
        )
    }

    private let rootStackView: UIStackView = .init()
    private let titleLabel: UILabel = .init()
    private let subtitleLabel: UILabel = .init()
    private let iconImageView: UIImageView = .init()
    private var icon: UIImage?
    private var stateAppearance: StateAppearance = .regular
    private var margins: UIEdgeInsets = .zero
    private var title: String = ""
    private var subtitle: String = ""
    private var appearance: Appearance {
        isEnabled ? stateAppearance.enabled : stateAppearance.disabled
    }

    override var isEnabled: Bool {
        didSet { updateEnabledStateUI() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        addTarget(self, action: #selector(viewTap), for: .touchUpInside)
        rootStackView.isUserInteractionEnabled = false

        addSubview(rootStackView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: self) +
                [
                    iconImageView.heightAnchor.constraint(equalToConstant: 24),
                    iconImageView.widthAnchor.constraint(equalToConstant: 24),
                ]
        )

        titleLabel.numberOfLines = 1
        subtitleLabel.numberOfLines = 3

        rootStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.axis = .horizontal
        rootStackView.alignment = .center
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
        verticalStack.addArrangedSubview(subtitleLabel)

        verticalStack.setCustomSpacing(6, after: titleLabel)

        updateUI()
    }

    private func updateUI() {
        rootStackView.layoutMargins = margins
        iconImageView.image = icon
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.isHidden = icon == nil
        titleLabel.isHidden = title.isEmpty
        subtitleLabel.isHidden = subtitle.isEmpty

    }

    private func updateEnabledStateUI() {
        titleLabel <~ appearance.titleStyle
        subtitleLabel <~ appearance.subtitleStyle
    }

    func set(
        title: String,
        subtitle: String,
        icon: UIImage? = UIImage(named: "right_arrow_icon_gray"),
        margins: UIEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15),
        stateAppearance: StateAppearance = .regular,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.margins = margins
        self.stateAppearance = stateAppearance
        updateUI()
    }

    var tapHandler: (() -> Void)?

    @objc private func viewTap() {
        tapHandler?()
    }
}
