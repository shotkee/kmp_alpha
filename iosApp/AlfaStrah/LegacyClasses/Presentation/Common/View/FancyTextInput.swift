//
//  FancyLabel.swift
//  FancyLabel
//
//  Created by Stanislav on 28/02/2017.
//  Copyright © 2017 Stanislav. All rights reserved.
//

import UIKit

// swiftlint:disable file_length

open class FancyTextInput: UIView, UITextFieldDelegate {
    typealias TextFieldActionCallback = (_ textField: UITextField) -> Void

    @objc var onEditingDidBegin: TextFieldActionCallback?
    @objc var onEditingDidEnd: TextFieldActionCallback?
    @objc var onReturnPressed: TextFieldActionCallback?
    @objc var onTextDidChange: TextFieldActionCallback?

    @objc let prefixLabel: UILabel = UILabel()
    @objc let descriptionLabel: UILabel = UILabel()
    @objc let textField: UITextField = UITextField()
    @objc let separatorView = HairLineView()

    @objc var prefixText: String? {
        didSet {
            prefixLabel.text = prefixText
        }
    }

    private var inputMask: SimpleTextMask?

    @objc var textMask: String {
        get {
            inputMask?.maskFormat ?? ""
        }
        set {
            inputMask = SimpleTextMask(format: newValue)
        }
    }

    @IBInspectable var alwaysShowsDescription: Bool = false {
        didSet {
            updateInternalConstraints()
            layoutIfNeeded()
        }
    }

    @IBInspectable var isRightIconVisible: Bool {
        get {
            textField.rightViewMode == .always
        }
        set {
            textField.rightViewMode = newValue ? .always : .never
        }
    }
    @IBInspectable var isLineSeparatorVisible: Bool {
        get {
            !separatorView.isHidden
        }
        set {
            separatorView.isHidden = !newValue
        }
    }

    @IBInspectable var descriptionHidesPlaceholderOnAppear: Bool = true
    @IBInspectable var descriptionCopiesPlaceholder: Bool = true

    @IBInspectable var placeholderFontSize: CGFloat = 15
    @IBInspectable var textLabelFontSize: CGFloat = 15

    @IBInspectable var descriptionLabelLeftInset: CGFloat = 0
    @IBInspectable var descriptionLabelTopInset: CGFloat = 0
    @IBInspectable var descriptionLabelRightInset: CGFloat = 0
    @IBInspectable var descriptionLabelSpaceToTextLabel: CGFloat = 0

    @IBInspectable var textFieldLeftInset: CGFloat = 0
    @IBInspectable var textFieldTopInset: CGFloat = 0
    @IBInspectable var textFieldRightInset: CGFloat = 0
    @IBInspectable var textFieldBottomInset: CGFloat = 0

    @IBInspectable var prefixLabelBottomInset: CGFloat = 8

    @IBInspectable var textFieldPlaceholderColor: UIColor = Style.Color.grayedText {
        didSet {
            if let placeholder = textField.placeholder {
                let attributedPlaceholder = NSMutableAttributedString(string: placeholder)
                let font = textField.font ?? UIFont.systemFont(ofSize: placeholderFontSize)
                let range = NSRange(location: 0, length: (placeholder as NSString).length)
                attributedPlaceholder.addAttributes([ .foregroundColor: textFieldPlaceholderColor, .font: font ], range: range)
                textField.attributedPlaceholder = attributedPlaceholder
            } else if let placeholder = textField.attributedPlaceholder?.mutable {
                let range = NSRange(location: 0, length: (placeholder.string as NSString).length)
                placeholder.addAttribute(.foregroundColor, value: textFieldPlaceholderColor, range: range)
            }
        }
    }

    @IBInspectable var textFieldUnactivePlaceholderColor: UIColor = Style.Color.Palette.lightGray

    var textFieldBorder: TextFieldBorderStyleAdapter = .none {
        didSet {
            textField.borderStyle = textFieldBorder.textFieldBorderStyle()
        }
    }

    func setEnabled(_ enableInput: Bool) {
        textField.isEnabled = enableInput
        textFieldPlaceholderColor = enableInput ? textFieldUnactivePlaceholderColor : textFieldPlaceholderColor
    }

    private var constraintsForShowingDescription: [NSLayoutConstraint] = []
    private var constraintsForHidingDescription: [NSLayoutConstraint] = []
    private var textFieldTopSpaceToSuperview: NSLayoutConstraint!
    private var prefixLabelWidthConstraint: NSLayoutConstraint!
    private var prefixLabelTailConstraint: NSLayoutConstraint!

    private var textFieldController: TextFieldController?
    private var textFieldPlaceholder: String?

    override open func awakeFromNib() {
        super.awakeFromNib()

        prepareSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        prepareSubviews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        CGSize(width: 300, height: 40)
    }

    func prepareSubviews() {
        if let ctrl = textFieldController {
            textField.delegate = ctrl
        } else {
            textField.delegate = self
            textField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
        }

        let views = subviewsDictionary()
        let metrics = layoutMetrics()

        descriptionLabel.numberOfLines = 0

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        prefixLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(descriptionLabel)
        addSubview(textField)
        addSubview(prefixLabel)
        addSubview(separatorView)

        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
        textField.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        separatorView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        prefixLabel.setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .horizontal)

        let carr0 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(TFLeftInset)-[PL]-[TF]-(TFRightInset)-|",
            metrics: metrics, views: views)
        let carr1 = NSLayoutConstraint.constraints(withVisualFormat: "V:[TF]-(TFBottomInset)-|", metrics: metrics, views: views)
        let carr2 = NSLayoutConstraint.constraints(withVisualFormat: "V:[PL]-(PLBottomInset)-|", metrics: metrics, views: views)
        activateConstraints(activate: true, inArray: carr0)
        activateConstraints(activate: true, inArray: carr1)
        activateConstraints(activate: true, inArray: carr2)

        prefixLabelWidthConstraint = NSLayoutConstraint(item: prefixLabel, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        textFieldTopSpaceToSuperview = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal,
            toItem: self, attribute: .top, multiplier: 1, constant: textFieldTopInset)
        prefixLabelTailConstraint = NSLayoutConstraint(item: prefixLabel, attribute: .trailing, relatedBy: .equal,
            toItem: textField, attribute: .leading, multiplier: 1, constant: 0)

        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            separatorView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
        ])
        separatorView.isHidden = true

        prefixLabelWidthConstraint.isActive = true
        prefixLabelTailConstraint.isActive = true

        constraintsForHidingDescription = constraintsForDescriptionLabelAnimationOnHide()
        constraintsForShowingDescription = constraintsForDescriptionLabelOnShow()

        updateInternalConstraints()

        prefixLabel.font = UIFont.systemFont(ofSize: textLabelFontSize)
        descriptionLabel.font = UIFont.systemFont(ofSize: placeholderFontSize)
        textField.font = UIFont.systemFont(ofSize: textLabelFontSize)

        addRightIconView()

        let customH: CGFloat = 32.0
        var subH = descriptionLabel.sizeThatFits(UIView.layoutFittingCompressedSize).height
        subH += textField.sizeThatFits(UIView.layoutFittingCompressedSize).height
        let customHeight = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .height, multiplier: 1, constant: max(customH, subH))
        let customWidth = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .width, multiplier: 1, constant: 100)
        customHeight.priority = .defaultLow
        customWidth.priority = .defaultLow
        superview?.addConstraint(customHeight)
        superview?.addConstraint(customWidth)
    }

    private func addRightIconView()
    {
        let rightIconView = UIImageView(
            image: UIImage(named: "icon-checkmark-red-small")
        )
        NSLayoutConstraint.activate([
            rightIconView.heightAnchor.constraint(equalToConstant: 24),
            rightIconView.widthAnchor.constraint(equalToConstant: 24),
        ])
        textField.rightView = rightIconView
        textField.rightViewMode = .never
    }

    @objc func set(textFieldController ctrl: TextFieldController) {
        ctrl.onReturnPressed = { [unowned self] textField in
            _ = self.textFieldShouldReturn(textField)
        }
        ctrl.onEditingDidBegin = { [unowned self] textField in
            self.textFieldDidBeginEditing(textField)
        }
        ctrl.onEditingDidEnd = { [unowned self] textField in
            self.textFieldDidEndEditing(textField)
        }
        ctrl.onTextDidChange = { [unowned self] textField in
            if let text = textField.text {
                self.updateTextField(text: text)
            }
            self.onTextDidChange?(textField)
        }
        textFieldController = ctrl
    }

    // MARK: - Border Style

    @IBInspectable var textFieldBorderStyle: Int {
        get {
            textFieldBorder.rawValue
        }
        set {
            textFieldBorder = TextFieldBorderStyleAdapter(rawValue: newValue) ?? .none
        }
    }

    enum TextFieldBorderStyleAdapter: Int {
        case none = 0
        case line = 1
        case bezel = 2
        case roundedRect = 3

        func textFieldBorderStyle() -> UITextField.BorderStyle {
            switch self {
                case .none:
                    return .none
                case .line:
                    return .line
                case .bezel:
                    return .bezel
                case .roundedRect:
                    return .roundedRect
            }
        }
    }

    @IBInspectable var textFieldBackgroundColor: UIColor? {
        get {
            textField.backgroundColor
        }
        set {
            textField.backgroundColor = newValue
        }
    }

    @IBInspectable var textFieldPlaceholderText: String? {
        get {
            textField.placeholder ?? textField.attributedPlaceholder?.string
        }
        set {
            guard let string = newValue else {
                textField.placeholder = nil
                textField.attributedPlaceholder = nil
                return
            }

            let mAttribStr = NSMutableAttributedString(string: string)
            let font = textField.font ?? UIFont.systemFont(ofSize: placeholderFontSize)
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: textFieldPlaceholderColor,
                .font: font
            ]
            let range = NSRange(location: 0, length: (string as NSString).length)
            mAttribStr.addAttributes(attributes, range: range)
            textField.attributedPlaceholder = mAttribStr
        }
    }

    @IBInspectable var textFieldTextColor: UIColor? {
        get {
            textField.textColor
        }
        set {
            textField.textColor = newValue
        }
    }

    // MARK: - Description

    @IBInspectable var descriptionBackgroundColor: UIColor? {
        get {
            descriptionLabel.backgroundColor
        }
        set {
            descriptionLabel.backgroundColor = newValue
        }
    }

    @IBInspectable var descriptionBorderColor: UIColor? {
        get {
            guard let cgColor = descriptionLabel.layer.borderColor else { return UIColor.black }

            return UIColor(cgColor: cgColor)
        }
        set {
            descriptionLabel.layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var descriptionBorderWidth: CGFloat {
        get {
            descriptionLabel.layer.borderWidth
        }
        set {
            descriptionLabel.layer.borderWidth = newValue
        }
    }

    @IBInspectable var descriptionText: String? {
        get {
            descriptionLabel.text
        }
        set {
            if descriptionCopiesPlaceholder {
                descriptionLabel.text = textFieldPlaceholderText
            } else {
                descriptionLabel.text = newValue
            }
        }
    }

    @IBInspectable var descriptionColor: UIColor {
        get {
            descriptionLabel.textColor
        }
        set {
            descriptionLabel.textColor = newValue
        }
    }

    func updateInternalConstraints() {
        if alwaysShowsDescription {
            activateConstraints(activate: false, inArray: constraintsForHidingDescription)
            activateConstraints(activate: true, inArray: constraintsForShowingDescription)
            textFieldTopSpaceToSuperview.isActive = false
            descriptionLabel.isHidden = false
        } else {
            activateConstraints(activate: false, inArray: constraintsForHidingDescription)
            activateConstraints(activate: false, inArray: constraintsForShowingDescription)
            textFieldTopSpaceToSuperview.isActive = true
            descriptionLabel.isHidden = true
        }
    }

    @objc func showDescription() {
        if !descriptionLabel.isHidden {
            return
        }

        if !alwaysShowsDescription {
            let font = descriptionLabel.font
            descriptionLabel.font = textField.font

            if descriptionCopiesPlaceholder {
                if textFieldPlaceholder == nil {
                    textFieldPlaceholder = textFieldPlaceholderText
                }
                textFieldPlaceholderText = nil
            }

            textFieldTopSpaceToSuperview.isActive = false
            activateConstraints(activate: true, inArray: constraintsForHidingDescription)
            descriptionLabel.isHidden = false
            layoutIfNeeded()

            activateConstraints(activate: true, inArray: constraintsForShowingDescription)
            activateConstraints(activate: false, inArray: constraintsForHidingDescription)
            prefixLabelWidthConstraint.isActive = false
            prefixLabelTailConstraint.constant = -5

            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.layoutIfNeeded()
                    self.descriptionLabel.font = font
                },
                completion: nil
            )
        }
    }

    func hideDescription() {
        guard !alwaysShowsDescription else { return }

        let font = descriptionLabel.font

        textFieldTopSpaceToSuperview.isActive = true
        layoutIfNeeded()

        activateConstraints(activate: false, inArray: constraintsForShowingDescription)
        activateConstraints(activate: true, inArray: constraintsForHidingDescription)
        prefixLabelWidthConstraint.isActive = true
        prefixLabelTailConstraint.constant = 0

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.layoutIfNeeded()
            },
            completion: { complete in
                guard complete else { return }

                self.descriptionLabel.alpha = 0.0
                self.textField.alpha = 1.0
                if self.descriptionCopiesPlaceholder {
                    self.textFieldPlaceholderText = self.textFieldPlaceholder
                    self.textFieldPlaceholder = nil
                }

                self.activateConstraints(activate: false, inArray: self.constraintsForHidingDescription)
                self.textFieldTopSpaceToSuperview.isActive = true
                self.descriptionLabel.isHidden = true
                self.descriptionLabel.font = font
                self.descriptionLabel.alpha = 1.0
                self.layoutIfNeeded()
            }
        )
    }

    // MARK: - Text Field

    open override var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    open override var canResignFirstResponder: Bool {
        textField.canResignFirstResponder
    }
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        showDescription()
        onEditingDidBegin?(textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        onEditingDidEnd?(textField)

        guard let text = textField.text as NSString? else {
            hideDescription()
            return
        }

        if text.length == 0 {
            hideDescription()
        }
    }
    var disableFirsteSpace: Bool = false

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if disableFirsteSpace {
            if range.location == 0, string == " " {
                return false
            }
        }
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.onReturnPressed?(textField)
        }
        return true
    }

    @objc public func textDidChange(textField: UITextField) {
        guard let mask = inputMask else {
            onTextDidChange?(textField)
            return
        }

        let newText = mask.mask(string: textField.text ?? "")
        textField.text = newText
        onTextDidChange?(textField)
    }

    @objc public func updateTextField(text: String) {
        if !text.isEmpty {
            showDescription()
        }

        guard let mask = inputMask else {
            textField.text = text
            onTextDidChange?(textField)
            return
        }

        let newText = mask.mask(string: text)
        textField.text = newText
        onTextDidChange?(textField)
    }

    // MARK: - Layout

    func subviewsDictionary() -> [String: UIView] {
        [
            "PL": prefixLabel,
            "DL": descriptionLabel,
            "TF": textField
        ]
    }

    func layoutMetrics() -> [String: Any] {
        [
            "DLLeftInset": descriptionLabelLeftInset,
            "DLTopInset": descriptionLabelTopInset,
            "DLRightInset": descriptionLabelRightInset,
            "DLSpaceToTF": descriptionLabelSpaceToTextLabel,
            "TFLeftInset": textFieldLeftInset,
            "TFTopInset": textFieldTopInset,
            "TFRightInset": textFieldRightInset,
            "TFBottomInset": textFieldBottomInset,
            "PLBottomInset": prefixLabelBottomInset
        ]
    }

    func constraintsForDescriptionLabelAnimationOnHide() -> [NSLayoutConstraint] {
        let views = subviewsDictionary()
        let metrics = layoutMetrics()

        let horizontal = "H:|-(TFLeftInset)-[DL]-(TFRightInset)-|"
        let vertical = "V:|-(TFTopInset)-[DL]-(TFBottomInset)-|"

        var result: [NSLayoutConstraint] = []
        result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: horizontal, metrics: metrics, views: views))
        result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: vertical, metrics: metrics, views: views))
        return result
    }

    func constraintsForDescriptionLabelOnShow() -> [NSLayoutConstraint] {
        let views = subviewsDictionary()
        let metrics = layoutMetrics()

        let horizontal = "H:|-(TFLeftInset)-[DL]-(TFRightInset)-|"
        let vertical = "V:|-(DLTopInset)-[DL]-(DLSpaceToTF)-[TF]"

        var res: [NSLayoutConstraint] = []
        res.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: horizontal, metrics: metrics, views: views))
        res.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: vertical, metrics: metrics, views: views))
        return res
    }

    func activateConstraints(activate active: Bool, inArray array: [NSLayoutConstraint]) {
        if active {
            NSLayoutConstraint.activate(array)
        } else {
            NSLayoutConstraint.deactivate(array)
        }
    }
}

// swiftlint:enable file_length
