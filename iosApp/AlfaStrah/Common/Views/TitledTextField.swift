//
// TitledTextField
// AlfaStrah
//
// Created by Alexander Babaev on 07 November 2016.
// Copyright (c) 2016 Redmadrobot. All rights reserved.
//

import UIKit

extension NSAttributedString {
    /// Returns specified attribute of the first symbol.
    func firstAttribute<Attribute>(name: NSAttributedString.Key) -> Attribute? {
        attribute(name, at: 0, effectiveRange: nil) as? Attribute
    }
}

/// TextField with a placeholder, that moves over the textField when something is entered or textField is being edited.
class TitledTextField: UITextField {
    override var text: String? {
        didSet {
            setNeedsLayout()
        }
    }

    override var attributedPlaceholder: NSAttributedString? {
        didSet {
            if attributedPlaceholder != nil {
                updateAttributedPlaceholder()
                attributedPlaceholder = nil
                placeholder = nil
            }
        }
    }

    override var placeholder: String? {
        didSet {
            if placeholder != nil {
                updatePlaceholder()
                attributedPlaceholder = nil
                placeholder = nil
            }
        }
    }

    /// Color of the placeholder (text when not editing and nothing is entered).
    @IBInspectable var placeholderColor: UIColor = .black {
        didSet {
            updatePlaceholderTitleParameters()
        }
    }

    /// Color of the title (text when we are editing or there is a text in a textField).
    @IBInspectable var titleColor: UIColor = .gray {
        didSet {
            updatePlaceholderTitleParameters()
        }
    }

    @IBInspectable var underlineEnabled: Bool = false {
        didSet {
            updateUnderlineParameters()
        }
    }
    @IBInspectable var underlineYCorrection: CGFloat = 0 {
        didSet {
            updateUnderlineParameters()
        }
    }
    @IBInspectable var underlineWidth: CGFloat = 1 {
        didSet {
            updateUnderlineParameters()
        }
    }
    @IBInspectable var underlineColor: UIColor = .lightGray {
        didSet {
            underlineView.backgroundColor = underlineColor
        }
    }

    /// Title scale (usually less than 1.0). Initial placeholder font is equal to its counterpart in the textField.
    @IBInspectable var titleScale: CGFloat = 0.75 {
        didSet {
            updatePlaceholderTitleParameters()
        }
    }

    /// This is a workaround for this bug: https://github.com/diogot/UITextFieldBug
    @IBInspectable var textEditingVerticalJumpCompensation: CGFloat = -0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    /// Title states.
    private enum TitleState {
        case title
        case placeholder
    }

    private let underlineView: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    private var titleState: TitleState = .placeholder

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    /// Sets up UI.
    private func setupUI() {
        clipsToBounds = false

        underlineView.autoresizingMask = [ .flexibleWidth, .flexibleTopMargin ]
        updateUnderlineParameters()

        addSubview(underlineView)
        addSubview(titleLabel)

        updateAttributedPlaceholder()
        attributedPlaceholder = nil
        placeholder = nil
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let result = super.editingRect(forBounds: bounds)
        return result.insetBy(dx: 0, dy: textEditingVerticalJumpCompensation)
    }

    /// Updates attributed placeholder.
    private func updateAttributedPlaceholder() {
        titleLabel.font = attributedPlaceholder?.firstAttribute(name: .font) ?? font

        let color: UIColor? = attributedPlaceholder?.firstAttribute(name: .foregroundColor)
        placeholderColor = color ?? placeholderColor
        titleLabel.textColor = placeholderColor

        titleLabel.text = attributedPlaceholder?.string ?? placeholder
        setNeedsLayout()
    }

    /// Updates placeholder.
    private func updatePlaceholder() {
        titleLabel.text = placeholder
        setNeedsLayout()
    }

    /// Updates placeholder title parameters.
    private func updatePlaceholderTitleParameters() {
        switch titleState {
            case .title:
                switchToTitle()
            case .placeholder:
                switchToPlaceholder()
        }
    }

    /// Updates underline parameters.
    private func updateUnderlineParameters() {
        let lineWidth: CGFloat = underlineWidth < 1 ? 1.0 / UIScreen.main.scale : underlineWidth
        underlineView.frame = CGRect(x: 0, y: bounds.height - lineWidth + underlineYCorrection, width: bounds.width, height: lineWidth)
        underlineView.backgroundColor = underlineColor
        underlineView.isHidden = !underlineEnabled
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let placeholderFrame = textRect(forBounds: bounds)

        if abs(placeholderFrame.width - titleLabel.bounds.width) > 0.1 || abs(placeholderFrame.height - titleLabel.bounds.height) > 0.1 {
            titleLabel.sizeToFit()
            titleLabel.bounds = CGRect(x: 0, y: 0, width: placeholderFrame.width, height: placeholderFrame.height)

            titleLabel.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            titleLabel.center = CGPoint(x: placeholderFrame.minX, y: placeholderFrame.midY)
            titleLabel.textAlignment = .left
            textAlignment = .left
        }

        let currentState = textFieldState()
        if currentState == .title && titleState == .placeholder {
            switchToTitle()
        } else if currentState == .placeholder && titleState == .title {
            switchToPlaceholder()
        }
        titleState = currentState
    }

    /// Returns state of the text field.
    private func textFieldState() -> TitleState {
        (isEditing || !(text?.isEmpty ?? true)) ? .title : .placeholder
    }

    // MARK: - Animations

    private let animationDuration: TimeInterval = 0.2

    /// Switches UI to show title and text.
    private func switchToTitle() {
        UIView.animate(withDuration: animationDuration) {
            let verticalOffset = self.textRect(forBounds: self.bounds).height + 7
            self.titleLabel.transform = CGAffineTransform(
                translationX: 0,
                y: -verticalOffset).scaledBy(x: self.titleScale, y: self.titleScale
            )
            self.titleLabel.textColor = self.titleColor

            let titleHeight = round((self.titleLabel.bounds.height * self.titleScale) / 2 + 2)
            self.transform = CGAffineTransform(translationX: 0, y: titleHeight)
            self.underlineView.transform = CGAffineTransform(translationX: 0, y: -titleHeight)
        }
    }

    /// Switches UI to show placeholder.
    private func switchToPlaceholder() {
        UIView.animate(withDuration: animationDuration) {
            self.titleLabel.transform = .identity
            self.titleLabel.textColor = self.placeholderColor

            self.transform = .identity
            self.underlineView.transform = .identity
        }
    }

    // MARK: - Actions

    /// Starts editing of the text field.
    @IBAction func showCursorAndStartEditing() {
        becomeFirstResponder()
    }
}
