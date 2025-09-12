//
//  MultilineInputField.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 06.08.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

/// NB: Присутствует только в DesignSystem v1.0
/// Основное назначение поля ввода – многострочный ввод текста.
/// Высота компонента фиксирована. Соответствует шести строкам текста заданного шрифта.
class TextAreaInputField: UIView, CommonNoteProtocol {
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var noteView: NoteView!
    @IBOutlet private var separatorView: HairLineView!
    @IBOutlet private var iconView: UIImageView!

    struct Appearance {
        let titleStyle: Style.Label.ColoredLabel
        let noteStyle: Style.TextView.ColoredTextView
        let placeholderLabelStyle: Style.Label.ColoredLabel

        private enum Constants {
            static let defaultTitleStyle = Style.Label.secondaryCaption1
            static let defaultNoteStyle = Style.TextView.primaryText
            static let defaultPlaceholderLabelStyle = Style.Label.secondaryText
        }

        init(
            titleStyle: Style.Label.ColoredLabel = Constants.defaultTitleStyle,
            noteStyle: Style.TextView.ColoredTextView = Constants.defaultNoteStyle,
            placeholderLabelStyle: Style.Label.ColoredLabel = Constants.defaultPlaceholderLabelStyle
        ) {
            self.titleStyle = titleStyle
            self.noteStyle = noteStyle
            self.placeholderLabelStyle = placeholderLabelStyle
        }

        static let regular = Appearance()
        static let header = Appearance(
            titleStyle: Style.Label.secondaryText,
            noteStyle: Style.TextView.primaryHeadline3,
            placeholderLabelStyle: Style.Label.secondaryText
        )
    }

    var textViewChangedCallback: ((UITextView) -> Void)? {
        get {
            noteView.textViewChangedCallback
        }
        set {
            noteView.textViewChangedCallback = newValue
        }
    }

    var textViewHeightChangedCallback: ((UITextView) -> Void)? {
        get {
            noteView.textViewHeightChangedCallback
        }
        set {
            noteView.textViewHeightChangedCallback = newValue
        }
    }

    var textViewDidBecomeActiveCallback: ((UITextView) -> Void)? {
        get {
            noteView.textViewDidBecomeActiveCallback
        }
        set {
            noteView.textViewDidBecomeActiveCallback = newValue
        }
    }

    var isEnabled: Bool {
        get {
            noteView.isEnabled
        }
        set {
            noteView.isEnabled = newValue
            noteView.isUserInteractionEnabled = newValue
        }
    }

    var currentText: String? {
        noteView.text
    }

    var numEnteredChars: Int {
        currentText?.count ?? 0
    }

    override var isFirstResponder: Bool {
        noteView.textView.isFirstResponder
    }

    func becomeActive() {
        noteView.becomeActive()
    }

    private var maxCharacterCount: CharsInputLimits = .unlimited
    private let appearance: Appearance = .regular
    private var title: String?
    private var note: String = ""
    private var placeholder: String?
    private let margins: UIEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    private var icon: UIImage?
    private var keyboardType: UIKeyboardType {
        get { noteView.textView.keyboardType }
        set { noteView.textView.keyboardType = newValue }
    }
    private var autocapitalizationType: UITextAutocapitalizationType {
        get { noteView.textView.autocapitalizationType }
        set { noteView.textView.autocapitalizationType = newValue }
    }

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        loadAndAddSubViewFromNib(name: "CommonNoteView")
        setup()
    }

    private func setup() {
        rootStackView.isLayoutMarginsRelativeArrangement = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

        translatesAutoresizingMaskIntoConstraints = false
        noteView.translatesAutoresizingMaskIntoConstraints = false
        noteView.automaticallyChangesHeight = false
        let textHeight = appearance.noteStyle.font.lineHeight * 6 + 1
        noteView.heightAnchor.constraint(equalToConstant: textHeight).isActive = true

        updateUI()
    }

    private func updateUI() {
        rootStackView.layoutMargins = margins

        iconView.image = icon
        let canValidate = !validationRules.isEmpty
        iconView.isHidden = icon == nil && !canValidate

        titleLabel <~ appearance.titleStyle
        noteView.textView <~ appearance.noteStyle
        noteView.setPlaceholderLabelStyle(appearance.placeholderLabelStyle)

        titleLabel.text = title
        titleLabel.isHidden = title == nil
        noteView.placeholderText = placeholder
        noteView.text = note
        validate()
    }

    func set(
        title: String?,
        note: String,
        placeholder: String = "",
        icon: UIImage? = nil,
        showSeparator: Bool = true,
        keyboardType: UIKeyboardType = .default,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        validationRules: [ValidationRule] = [],
        showValidInputIcon: Bool = true,
        maxCharacterCount: CharsInputLimits = .unlimited
    ) {
        self.title = title
        self.note = note
        self.placeholder = placeholder
        self.icon = icon
        self.separatorView.isHidden = !showSeparator
        self.validationRules = validationRules
        self.showValidInputIcon = showValidInputIcon
        self.maxCharacterCount = maxCharacterCount
        self.keyboardType = keyboardType
        self.autocapitalizationType = autocapitalizationType
        noteView.noteMaxLength = maxCharacterCount.value

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
    private var showValidInputIcon = true

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
        if shoudValidate && isValid && showValidInputIcon {
            iconView.image = UIImage(named: "icon-checkmark-red-small")
        } else {
            iconView.image = icon
        }
    }
}
