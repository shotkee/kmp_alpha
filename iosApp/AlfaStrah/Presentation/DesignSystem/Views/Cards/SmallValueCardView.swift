//
//  SmallValueCardView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

/// Находятся в группе карточек, объединенные по смыслу или принадлежащие одной категории.
/// Применяются для перехода в модальное окно, в котором будет заполнение через поле ввода
class SmallValueCardView: HighlightableCardView {
    struct Appearance {
        let titleStyle: Style.Label.ColoredLabel
        let placeholderStyle: Style.Label.ColoredLabel
        let valueStyle: Style.Label.ColoredLabel
        let errorStyle: Style.Label.ColoredLabel
        let isIconHidden: Bool
    }

    struct StateAppearance {
        let enabled: Appearance
        let disabled: Appearance

        static let regular: StateAppearance = StateAppearance(
            enabled: Appearance(
                titleStyle: Style.Label.secondaryCaption1,
                placeholderStyle: Style.Label.secondaryText,
                valueStyle: Style.Label.primaryText,
                errorStyle: Style.Label.accentCaption1,
                isIconHidden: false
            ),
            disabled: Appearance(
                titleStyle: Style.Label.secondaryCaption1,
                placeholderStyle: Style.Label.secondaryText,
                valueStyle: Style.Label.secondaryText,
                errorStyle: Style.Label.accentCaption1,
                isIconHidden: true

            )
        )
        
        static let noPossibilityEdit: StateAppearance = StateAppearance(
            enabled: Appearance(
                titleStyle: Style.Label.secondaryCaption1,
                placeholderStyle: Style.Label.secondaryText,
                valueStyle: Style.Label.primaryText,
                errorStyle: Style.Label.accentCaption1,
                isIconHidden: false
            ),
            disabled: Appearance(
                titleStyle: Style.Label.secondaryCaption1,
                placeholderStyle: Style.Label.secondaryText,
                valueStyle: Style.Label.primaryText,
                errorStyle: Style.Label.accentCaption1,
                isIconHidden: false
            )
        )
    }

    enum IconPositionStyle {
        case top(_ icon: UIImage?)
        case center(_ icon: UIImage?)

        var icon: UIImage? {
            switch self {
                case .top(let icon):
                    return icon
                case .center(let icon):
                    return icon
            }
        }

		static let rightArrow: IconPositionStyle = .center(.Icons.chevronCenteredSmallRight.tintedImage(withColor: .Icons.iconSecondary))
        static let empty: IconPositionStyle = .center(nil)
    }

    private let rootStackView: UIStackView = .init()
    private let titleLabel: UILabel = .init()
    private let placeholderLabel: UILabel = .init()
    private let valueLabel: UILabel = .init()
    private let errorLabel: UILabel = .init()
    private let iconImageView: UIImageView = .init()

    private var iconPositionStyle: IconPositionStyle = IconPositionStyle.rightArrow
    private var stateAppearance: StateAppearance = .regular
    private var margins: UIEdgeInsets = .zero
    private var title: String = ""
    private var placeholder: String = ""
    private var error: String?
    private var value: String?

    private var appearance: Appearance {
        isEnabled ? stateAppearance.enabled : stateAppearance.disabled
    }

    private lazy var separatorView: HairLineView = {
        let separator: HairLineView = .init(frame: .zero)
		separator.lineColor = .Stroke.divider

        return separator
    }()

    override var isEnabled: Bool {
        didSet { updateEnabledStateUI() }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        addTarget(self, action: #selector(viewTap), for: .touchUpInside)
        rootStackView.isUserInteractionEnabled = false

        addSubview(rootStackView)
        addSubview(separatorView)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: rootStackView, in: self) +
            [
                separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
                separatorView.leftAnchor.constraint(equalTo: leftAnchor),
                separatorView.rightAnchor.constraint(equalTo: rightAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1),

                iconImageView.heightAnchor.constraint(equalToConstant: 24),
                iconImageView.widthAnchor.constraint(equalToConstant: 24),
                heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
            ]
        )

        titleLabel.numberOfLines = 1
        placeholderLabel.numberOfLines = 2
        valueLabel.numberOfLines = 5
        errorLabel.numberOfLines = 2

        rootStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.axis = .horizontal
        rootStackView.alignment = .fill
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
        verticalStack.addArrangedSubview(placeholderLabel)
        verticalStack.addArrangedSubview(valueLabel)
        verticalStack.addArrangedSubview(errorLabel)

        verticalStack.setCustomSpacing(3, after: titleLabel)
        verticalStack.setCustomSpacing(3, after: valueLabel)

        updateUI()
    }

    private func updateUI() {
        rootStackView.layoutMargins = margins
        switch iconPositionStyle {
            case .center:
                rootStackView.alignment = .center
            case .top:
                rootStackView.alignment = .top
        }

        iconImageView.image = iconPositionStyle.icon
        titleLabel.text = title
        placeholderLabel.text = placeholder
        valueLabel.text = value
        errorLabel.text = error

        iconImageView.isHidden = iconPositionStyle.icon == nil
        titleLabel.isHidden = title.isEmpty || (value ?? "").isEmpty
        placeholderLabel.isHidden = placeholder.isEmpty || !(value ?? "").isEmpty
        valueLabel.isHidden = (value ?? "").isEmpty
        errorLabel.isHidden = (error ?? "").isEmpty
    }

    private func updateEnabledStateUI() {
        titleLabel <~ appearance.titleStyle
        placeholderLabel <~ appearance.placeholderStyle
        valueLabel <~ appearance.valueStyle
        errorLabel <~ appearance.errorStyle
        iconImageView.isHidden = appearance.isIconHidden
    }

    func set(
        title: String,
        placeholder: String,
        value: String?,
        error: String?,
        icon: IconPositionStyle = .rightArrow,
        margins: UIEdgeInsets = UIEdgeInsets(top: 9, left: 15, bottom: 9, right: 15),
        stateAppearance: StateAppearance = .regular,
        isEnabled: Bool = true,
        showSeparator: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self.value = value
        self.error = error
        iconPositionStyle = icon
        self.margins = margins
        self.stateAppearance = stateAppearance
        self.isEnabled = isEnabled
        self.separatorView.isHidden = !showSeparator

        updateUI()
    }

    func getValue() -> String {
        value ?? ""
    }

    func update(value: String?) {
        self.value = value
        updateUI()
    }

    func update(error: String?) {
        self.error = error
        updateUI()
    }

    var tapHandler: (() -> Void)?

    @objc private func viewTap() {
        tapHandler?()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let image = iconImageView.image
		
		iconImageView.image = image?.tintedImage(withColor: .Icons.iconSecondary)
	}
}
