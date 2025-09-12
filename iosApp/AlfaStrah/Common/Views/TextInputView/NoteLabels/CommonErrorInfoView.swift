//
//  CommonNoteLabelWithErrorView.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 26.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class CommonErrorInfoView: UIView, CommonNoteProtocol {
    struct Appearance {
        let titleStyle: Style.Label.ColoredLabel
        let noteStyle: Style.Label.ColoredLabel
        let errorStyle: Style.Label.ColoredLabel

        private enum Constants {
            static let defaultTitleStyle = Style.Label.primaryCaption1
            static let defaultNoteStyle = Style.Label.primaryHeadline1
            static let defaultErrorStyle = Style.Label.accentCaption1
        }

        init(
            titleStyle: Style.Label.ColoredLabel = Constants.defaultTitleStyle,
            noteStyle: Style.Label.ColoredLabel = Constants.defaultNoteStyle,
            errorStyle: Style.Label.ColoredLabel = Constants.defaultErrorStyle
        ) {
            self.titleStyle = titleStyle
            self.noteStyle = noteStyle
            self.errorStyle = errorStyle
        }

        static let regular = Appearance()
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
        stack.spacing = 0

        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ appearance.titleStyle
        label.numberOfLines = 1

        return label
    }()

    private lazy var noteLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ appearance.noteStyle
        label.numberOfLines = 1

        return label
    }()

    private lazy var errorLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ appearance.errorStyle
        label.numberOfLines = 0

        return label
    }()

    private lazy var separatorView: HairLineView = {
        let separator: HairLineView = .init(frame: .zero)
        separator.lineColor = Style.Color.Palette.lightGray

        return separator
    }()

    private lazy var iconImageView: UIImageView = .init(frame: .zero)

    var currentText: String? {
        note
    }

    private var appearance: Appearance = .regular
    private var title: String?
    private var note: String = ""
    private var margins: UIEdgeInsets = .zero
    private var icon: UIImage?
    private var errorType: ErrorType = .noError

    enum ErrorType {
        case hasErrorText(_ errorString: String?)
        case hasError
        case noError
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
        backgroundColor = Style.Color.Palette.white
        addSubview(rootStackView)
        addSubview(separatorView)

        rootStackView.addArrangedSubview(containerStackView)

        containerStackView.addArrangedSubview(contentStackView)
        containerStackView.addArrangedSubview(iconImageView)

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(noteLabel)
        contentStackView.addArrangedSubview(errorLabel)

        contentStackView.setCustomSpacing(9, after: titleLabel)
        contentStackView.setCustomSpacing(4, after: noteLabel)

        containerStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            rootStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15),
            rootStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),

            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            iconImageView.widthAnchor.constraint(equalToConstant: 24)
        ])

        updateUI()
    }

    private func updateUI() {
        containerStackView.layoutMargins = margins
        iconImageView.image = icon
        titleLabel.text = title
        noteLabel.text = note

        switch errorType {
            case .hasErrorText(let text):
                errorLabel.text = text
                containerStackView.alpha = 1.0
            case .hasError:
                errorLabel.text = nil
                containerStackView.alpha = 1.0
            case .noError:
                errorLabel.text = nil
                containerStackView.alpha = 0.5
        }
    }

    func set(
        title: String?,
        note: String,
        errorType: ErrorType,
        icon: String?,
        margins: UIEdgeInsets = .zero,
        showSeparator: Bool = false,
        appearance: Appearance = .regular
    ) {
        self.title = title
        self.note = note
        self.errorType = errorType
        self.margins = margins
        self.separatorView.isHidden = !showSeparator
        self.appearance = appearance
        self.icon = UIImage(named: icon ?? "")

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

    func validate() { }
}
