//
//  CommonNoteLabelView.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 10.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class CommonNoteLabelView: UIView, CommonNoteProtocol {
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
    }

    struct Appearance {
        let titleStyle: Style.Label.ColoredLabel
        let noteStyle: Style.Label.ColoredLabel
        let placeholderLabelStyle: Style.Label.ColoredLabel

        private enum Constants {
            static let defaultTitleStyle = Style.Label.secondaryCaption1
            static let defaultNoteStyle = Style.Label.primaryText
            static let defaultPlaceholderLabelStyle = Style.Label.secondaryText
        }

        init(
            titleStyle: Style.Label.ColoredLabel = Constants.defaultTitleStyle,
            noteStyle: Style.Label.ColoredLabel = Constants.defaultNoteStyle,
            placeholderLabelStyle: Style.Label.ColoredLabel = Constants.defaultPlaceholderLabelStyle
        ) {
            self.titleStyle = titleStyle
            self.noteStyle = noteStyle
            self.placeholderLabelStyle = placeholderLabelStyle
        }

        static let regular = Appearance()
        static let regularTitle = Appearance(
            titleStyle: Style.Label.primaryHeadline2,
            noteStyle: Style.Label.secondaryText,
            placeholderLabelStyle: Constants.defaultPlaceholderLabelStyle
        )
        static let regularBoldInfo = Appearance(
            titleStyle: Style.Label.primaryCaption1,
            noteStyle: Style.Label.primaryHeadline1,
            placeholderLabelStyle: Style.Label.tertiaryHeadline1
        )
        static let header = Appearance(
            titleStyle: Style.Label.secondaryText,
            noteStyle: Style.Label.primaryHeadline3,
            placeholderLabelStyle: Style.Label.secondaryText
        )
        static let bold = Appearance(
            titleStyle: Constants.defaultTitleStyle,
            noteStyle: Style.Label.primaryHeadline3,
            placeholderLabelStyle: Constants.defaultPlaceholderLabelStyle
        )
        static let error = Appearance(
            titleStyle: Style.Label.accentCaption1,
            noteStyle: Style.Label.primaryText,
            placeholderLabelStyle: Constants.defaultPlaceholderLabelStyle
        )
    }

    private lazy var rootStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .top
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 0

        return stack
    }()

    private lazy var containerStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .center
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 20

        return stack
    }()

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 4

        return stack
    }()

    private lazy var titleStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 0

        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.numberOfLines = 1

        return label
    }()

    private lazy var noteLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.numberOfLines = 0

        return label
    }()

    private lazy var separatorView: HairLineView = {
        let separator: HairLineView = .init(frame: .zero)
		separator.lineColor = .Stroke.divider

        return separator
    }()

    private lazy var iconImageView: UIImageView = .init(frame: .zero)

    private var iconPositionStyle: IconPositionStyle = .center(nil)

    func setIconAnchorType(_ type: IconPositionStyle) {
        iconPositionStyle = type
        layoutInterface()
    }

    var currentText: String? {
        note
    }

    private var appearance: Appearance = .regular
    private var appearanceError: Appearance?
    private var title: String?
    private var note: String = ""
    private var placeholder: String?
    private var margins: UIEdgeInsets = .zero
    private var icon: UIImage? {
        iconPositionStyle.icon
    }

    // MARK: Init

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
		backgroundColor = .clear
        addSubview(rootStackView)
        addSubview(separatorView)

        containerStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootStackView.leftAnchor.constraint(equalTo: leftAnchor),
            rootStackView.rightAnchor.constraint(equalTo: rightAnchor),

            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            iconImageView.widthAnchor.constraint(equalToConstant: 24)
        ])

        layoutInterface()
        updateUI()
    }

    private func layoutInterface() {
        rootStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rootStackView.addArrangedSubview(containerStackView)

        containerStackView.addArrangedSubview(contentStackView)

        switch iconPositionStyle {
            case .top:
                contentStackView.addArrangedSubview(titleStackView)
                contentStackView.addArrangedSubview(noteLabel)

                titleStackView.addArrangedSubview(titleLabel)
                titleStackView.addArrangedSubview(iconImageView)

            case .center:
                containerStackView.addArrangedSubview(iconImageView)
                contentStackView.addArrangedSubview(titleLabel)
                contentStackView.addArrangedSubview(noteLabel)
        }
    }

    private func updateUI() {
        containerStackView.layoutMargins = margins

        iconImageView.image = icon
		iconImageView.contentMode = .center
        let canValidate = !validationRules.isEmpty
        iconImageView.isHidden = icon == nil && !canValidate

        titleLabel.text = title
        titleLabel.isHidden = title == nil

        noteLabel.text = note.isEmpty ? placeholder : note

        validate()
    }

    func set(
        title: String?,
        note: String,
        placeholder: String = "",
        style: IconPositionStyle = .center(nil),
        margins: UIEdgeInsets = .zero,
        showSeparator: Bool = true,
        appearance: Appearance = .regular,
        appearanceError: Appearance? = nil,
        validationRules: [ValidationRule] = []
    ) {
        self.title = title
        self.note = note
        self.placeholder = placeholder
        self.margins = margins
        self.separatorView.isHidden = !showSeparator
        self.appearance = appearance
        self.appearanceError = appearanceError
        self.validationRules = validationRules

        setIconAnchorType(style)
        updateUI()
    }

    var tapHandler: (() -> Void)?

    func updateText(_ text: String) {
        note = text
        updateUI()
    }

    @objc private func viewTap() {
        tapHandler?()
    }

    // MARK: - Validation

    private var validationRules: [ValidationRule] = []

    private var shoudValidate: Bool {
        !validationRules.isEmpty
    }

    var isValid: Bool {
        guard shoudValidate else { return true }

        var isValid = true

        mainLoop: for rule in validationRules {
            switch rule.validate(currentText ?? "") {
                case .success:
                    continue
                case .failure:
                    isValid = false
                    break mainLoop
            }
        }

        return isValid
    }

    func validate() {
        if isValid {
			iconImageView.image = shoudValidate
				? .Icons.tick.tintedImage(withColor: .Icons.iconAccent)
					.resized(newWidth: 16)?
					.withRenderingMode(.alwaysTemplate)
				: icon
			
            titleLabel <~ appearance.titleStyle
            noteLabel <~ (note.isEmpty ? appearance.placeholderLabelStyle : appearance.noteStyle)
        } else {
            iconImageView.image = icon
            if let appearanceError = appearanceError {
                titleLabel <~ appearanceError.titleStyle
                noteLabel <~ (note.isEmpty ? appearanceError.placeholderLabelStyle : appearanceError.noteStyle)
            } else {
                titleLabel <~ appearance.titleStyle
                noteLabel <~ (note.isEmpty ? appearance.placeholderLabelStyle : appearance.noteStyle)
            }
        }
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		if let image = iconImageView.image {
			switch image.renderingMode {
				case .automatic, .alwaysOriginal:
					iconImageView.image = image
				case .alwaysTemplate:
					iconImageView.image = image.tintedImage(withColor: .Icons.iconAccent)
				default:
					iconImageView.image = image
			}
		}
	}
}
