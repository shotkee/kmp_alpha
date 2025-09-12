//
//  ValueCardView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 12.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

/// Главное назначение карточки – показать, заполнено поле или нет.
class ValueCardView: HighlightableCardView {
    struct Appearance {
        let titleStyle: Style.Label.ColoredLabel
        let placeholderStyle: Style.Label.ColoredLabel
        let valueStyle: Style.Label.ColoredLabel
        let errorStyle: Style.Label.ColoredLabel
    }
    
    struct StateAppearance {
        let enabled: Appearance
        let disabled: Appearance
        
        static let regular: StateAppearance = StateAppearance(
            enabled: Appearance(
                titleStyle: Style.Label.primaryCaption1,
                placeholderStyle: Style.Label.tertiaryHeadline1,
                valueStyle: Style.Label.primaryHeadline1,
                errorStyle: Style.Label.accentCaption1
            ),
            disabled: Appearance(
                titleStyle: Style.Label.secondaryCaption1,
                placeholderStyle: Style.Label.tertiaryHeadline1,
                valueStyle: Style.Label.secondaryHeadline1,
                errorStyle: Style.Label.accentCaption1
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
        static let delete: IconPositionStyle = .center(
			.Icons.cross.resized(newWidth: 54)?
				.tintedImage(withColor: .Icons.iconSecondary)
				.withRenderingMode(.alwaysTemplate)
		)
		static let photo: IconPositionStyle = .center(.Icons.camera.tintedImage(withColor: .Icons.iconSecondary))
        static let empty: IconPositionStyle = .center(UIImage())
    }
    
    private let titleLabel: UILabel = .init()
    private let placeholderLabel: UILabel = .init()
    private let valueLabel: UILabel = .init()
    private let errorLabel: UILabel = .init()
    
    private let iconButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(iconTap), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    private lazy var iconButtonTopConstraint = iconButton.topAnchor.constraint(equalTo: topAnchor, constant: 15)
    private lazy var iconButtonCenterYContraint = iconButton.centerYAnchor.constraint(equalTo: centerYAnchor)
    
    private var iconPositionStyle: IconPositionStyle = IconPositionStyle.rightArrow
    private var stateAppearance: StateAppearance = .regular
    
    private var title: String = ""
    private var attributedTitle: NSMutableAttributedString?
    private var placeholder: String = ""
    private var value: String?
    private var error: String?
    
    private var appearance: Appearance {
        isEnabled ? stateAppearance.enabled : stateAppearance.disabled
    }
    
    private lazy var separatorView: HairLineView = {
        let separator: HairLineView = .init(frame: .zero)
        separator.lineColor = Style.Color.Palette.lightGray
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
        
        let verticalStack: UIStackView = .init()
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.distribution = .fill
        verticalStack.spacing = 0
        verticalStack.isUserInteractionEnabled = false
        
        addSubview(verticalStack)
        addSubview(iconButton)
        addSubview(separatorView)
        
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                verticalStack.topAnchor.constraint(equalTo: topAnchor, constant: 15),
                verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
                iconButton.leadingAnchor.constraint(equalTo: verticalStack.trailingAnchor, constant: 9),
                iconButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
                separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
                separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1),
                
                iconButton.heightAnchor.constraint(equalToConstant: 24),
                iconButton.widthAnchor.constraint(equalToConstant: 24),
            ]
        )
        titleLabel.numberOfLines = 1
        placeholderLabel.numberOfLines = 1
        valueLabel.numberOfLines = 0
        errorLabel.numberOfLines = 2
        
        verticalStack.addArrangedSubview(titleLabel)
        verticalStack.addArrangedSubview(placeholderLabel)
        verticalStack.addArrangedSubview(valueLabel)
        verticalStack.addArrangedSubview(errorLabel)
        
        verticalStack.setCustomSpacing(6, after: titleLabel)
        verticalStack.setCustomSpacing(3, after: valueLabel)
        
        updateUI()
    }
    
    private func updateUI() {
        switch iconPositionStyle {
            case .center:
                iconButtonCenterYContraint.isActive = true
                iconButtonTopConstraint.isActive = false
            case .top:
                iconButtonTopConstraint.isActive = true
                iconButtonCenterYContraint.isActive = false
        }
        
        iconButton.setImage(iconPositionStyle.icon, for: .normal)
        
        if let attributedTitle = self.attributedTitle {
            titleLabel.attributedText = attributedTitle
        } else {
            titleLabel.text = title
        }
        
        placeholderLabel.text = placeholder
        valueLabel.text = value
        errorLabel.text = error
        
        iconButton.isHidden = iconPositionStyle.icon == nil
        titleLabel.isHidden = title.isEmpty
        placeholderLabel.isHidden = placeholder.isEmpty || !(value ?? "").isEmpty
        valueLabel.isHidden = (value ?? "").isEmpty
        errorLabel.isHidden = (error ?? "").isEmpty
    }
    
    private func updateEnabledStateUI() {
        titleLabel <~ appearance.titleStyle
        placeholderLabel <~ appearance.placeholderStyle
        valueLabel <~ appearance.valueStyle
        errorLabel <~ appearance.errorStyle
    }
    
    func set(
        title: String,
        placeholder: String,
        value: String?,
        error: String?,
        icon: IconPositionStyle = IconPositionStyle.rightArrow,
        stateAppearance: StateAppearance = .regular,
        isEnabled: Bool = true,
        showSeparator: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self.value = value
        self.error = error
        iconPositionStyle = icon
        self.stateAppearance = stateAppearance
        self.isEnabled = isEnabled
        self.separatorView.isHidden = !showSeparator
        
        updateUI()
    }
    
    func update(value: String?) {
        self.value = value
        updateUI()
    }
    
    func update(error: String?) {
        self.error = error
        updateUI()
    }
    
    func update(title: NSMutableAttributedString) {
        self.attributedTitle = title
        updateUI()
    }

    var tapHandler: (() -> Void)?
    var iconTapHandler: (() -> Void)? {
        didSet {
            iconButton.isUserInteractionEnabled = iconTapHandler != nil
        }
    }

    @objc private func viewTap() {
        tapHandler?()
    }

    @objc private func iconTap() {
        iconTapHandler?()
    }
    
    func set(attributedSubtitle: NSAttributedString) {
        titleLabel.attributedText = attributedSubtitle
        updateUI()
    }
        
    func resetAttributedSubtitle() {
        attributedTitle = nil
        updateUI()
    }
}
