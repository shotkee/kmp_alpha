//
//  CommonNoteView.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class CommonNoteView: UIView, CommonNoteProtocol {
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

    var charsLeftCounter: Int? {
        maxCharacterCount.isNeedIndicatorShow
            ? noteView.noteMaxLength - (currentText?.count ?? 0)
            : nil
    }

    override var isFirstResponder: Bool {
        noteView.textView.isFirstResponder
    }

    func becomeActive() {
        noteView.becomeActive()
    }

    private var maxCharacterCount: CharsInputLimits = .unlimited
    private var appearance: Appearance = .regular
    private var title: String?
    private var note: String = ""
    private var placeholder: String?
    private var margins: UIEdgeInsets = .zero
    private var icon: UIImage?
    private var keyboardType: UIKeyboardType {
        get {
            noteView.textView.keyboardType
        }
        set {
            noteView.textView.keyboardType = newValue
        }
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
        addSelfAsSubviewFromNib()
        setup()
    }

    private func setup() {
        iconView.tintColor = .Icons.iconAccent
        
        rootStackView.isLayoutMarginsRelativeArrangement = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

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
        margins: UIEdgeInsets = .zero,
        showSeparator: Bool = true,
        appearance: Appearance = .regular,
        keyboardType: UIKeyboardType = .default,
        validationRules: [ValidationRule] = [],
        maxCharacterCount: CharsInputLimits = .unlimited
    ) {
        self.title = title
        self.note = note
        self.placeholder = placeholder
        self.icon = icon
        self.margins = margins
        self.separatorView.isHidden = !showSeparator
        self.appearance = appearance
        self.validationRules = validationRules
        self.maxCharacterCount = maxCharacterCount
        self.keyboardType = keyboardType
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
        if shoudValidate && isValid {
            iconView.image = UIImage(named: "icon-checkmark-red-small")
        } else {
            iconView.image = icon
        }
    }
}
