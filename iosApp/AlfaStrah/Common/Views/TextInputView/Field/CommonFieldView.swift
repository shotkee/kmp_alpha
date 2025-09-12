//
//  CommonFieldView
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 29.01.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import InputMask

enum ContentMasks {
    static let noteAccountNumber = "[0] [0000] [0000] [0000] [0000] [000]"
    static let inputAccountNumber = "[0000] [0000] [0000] [0000] [0000]"
}

class CommonFieldView: UIView, MaskedTextFieldDelegateListener, CommonNoteProtocol {
    @IBOutlet private var listener: MaskedTextFieldDelegate!
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var separatorView: HairLineView!
    @IBOutlet private var iconView: UIImageView!

    struct Appearance {
        let titleStyle: Style.Label.ColoredLabel
        let textStyle: Style.TextField.ColoredTextField
        let placeholderTextAttributes: [NSAttributedString.Key: Any]

        private enum Constants {
            static let defaultTitleStyle = Style.Label.secondaryCaption1
            static let defaultTextStyle = Style.TextField.primaryText
            static let defaultPlaceholderStyle = Style.TextAttributes.grayInfoText
        }

        init(
            titleStyle: Style.Label.ColoredLabel = Constants.defaultTitleStyle,
            textStyle: Style.TextField.ColoredTextField = Constants.defaultTextStyle,
            placeholderTextAttributes: [NSAttributedString.Key: Any] = Constants.defaultPlaceholderStyle
        ) {
            self.titleStyle = titleStyle
            self.textStyle = textStyle
            self.placeholderTextAttributes = placeholderTextAttributes
        }

        static let regular = Appearance()
        static let header = Appearance(
            titleStyle: Style.Label.secondaryText,
            textStyle: Style.TextField.primaryHeadline3,
            placeholderTextAttributes: Style.TextAttributes.grayInfoText
        )
    }

    var textFieldChangedCallback: ((UITextField) -> Void)?
    var textFieldFinishedEditingCallback: ((UITextField) -> Void)?
    var textFieldDidBecomeActiveCallback: ((UITextField) -> Void)?

    var isEnabled: Bool {
        get {
            textField.isEnabled
        }
        set {
            textField.isEnabled = newValue
            textField.isUserInteractionEnabled = newValue
        }
    }

    var currentText: String? {
        currentNoteText
    }

    var charsLeftCounter: Int? {
        maxCharacterCount.isNeedIndicatorShow
            ? fieldMaxLength - (currentNoteText.count)
            : nil
    }
    
    override var isFirstResponder: Bool {
        textField.isFirstResponder
    }

    private var fieldMaxLength: Int {
        maxCharacterCount.value
    }
    
    private var currentNoteText: String = ""
    private var maxCharacterCount: CharsInputLimits = .unlimited
    private var appearance: Appearance = .regular
    private var title: String?
    private var placeholder: String = ""
    private var contentMask: String?
    private var margins: UIEdgeInsets = .zero
    private var icon: UIImage?
    
    private var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    private var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }
    
    private var preventInputOnLimit: Bool = false

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
        
        if contentMask != nil {
            listener.delegate = self
            textField.delegate = listener
        } else {
            textField.delegate = self
        }

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
        textField <~ appearance.textStyle

        titleLabel.text = title
        titleLabel.isHidden = title == nil
        textField.attributedPlaceholder = placeholder <~ appearance.placeholderTextAttributes

        if let mask = contentMask {
            listener.primaryMaskFormat = mask
            listener.put(
                text: currentNoteText,
                into: textField
            )
        } else {
            textField.text = currentText
        }

        validate()
    }

    func set(
        title: String? = nil,
        text: String,
        placeholder: String = "",
        icon: UIImage? = nil,
        margins: UIEdgeInsets = .zero,
        showSeparator: Bool = true,
        appearance: Appearance = .regular,
        keyboardType: UIKeyboardType = .default,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        validationRules: [ValidationRule] = [],
        maxCharacterCount: CharsInputLimits = .unlimited,
        contentMask: String? = nil,
        preventInputOnLimit: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self.margins = margins
        self.appearance = appearance
        self.keyboardType = keyboardType
        self.autocapitalizationType = autocapitalizationType
        self.validationRules = validationRules
        self.maxCharacterCount = maxCharacterCount
        self.contentMask = contentMask
        self.preventInputOnLimit = preventInputOnLimit
        
        currentNoteText = text
        separatorView.isHidden = !showSeparator

        updateUI()
    }

    var tapHandler: (() -> Void)?

    func updateText(_ text: String) {
        currentNoteText = text
        updateUI()
    }

    func becomeActive() {
        textField.becomeFirstResponder()
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
            switch rule.validate(currentNoteText) {
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
            iconView.image = UIImage.Icons.check
        } else {
            iconView.image = icon
        }
    }

    // MARK: - MaskedTextFieldDelegate

    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        currentNoteText = value
        textFieldChangedCallback?(textField)
    }

    // MARK: - UITextViewDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldDidBecomeActiveCallback?(textField)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldFinishedEditingCallback?(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch self.maxCharacterCount {
            case .unlimited:
                return true
            case .limited(let upperBound):
                if self.preventInputOnLimit {
                    if let currentText = self.currentText {
                        guard let stringRange = Range(range, in: currentText) else { return true }
                        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
                        
                        return updatedText.count <= upperBound
                    } else { return true }
                } else {
                    return true
                }
        }
    }

    @IBAction func texFieldDidChanged(_ sender: UITextField) {
        currentNoteText = sender.text ?? ""
        textFieldChangedCallback?(sender)
    }
}
