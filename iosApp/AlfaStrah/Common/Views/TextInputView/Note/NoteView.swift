//
//  NoteView.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

/// View for the note editing or showing.
class NoteView: UIView, UITextViewDelegate {
    var textViewDidBecomeActiveCallback: ((UITextView) -> Void)?
    var textViewChangedCallback: ((UITextView) -> Void)?
    var textViewHeightChangedCallback: ((UITextView) -> Void)?
    var textViewFinishedEditingCallback: ((UITextView) -> Void)?
    var textViewReturnKeyCallback: (() -> Void)?

    var text: String? {
        get {
            textView.text
        }
        set(text) {
            textView.text = text ?? ""
            textView.contentOffset = .zero
            updateTextView(animated: false)
        }
    }

    var placeholderText: String? {
        didSet {
            if let placeholderText = placeholderText {
                placeholderLabel.text = placeholderText
            }
        }
    }

    var isEnabled: Bool {
        get {
            textView.isEditable
        }
        set {
            textView.isEditable = newValue
        }
    }

    var automaticallyChangesHeight: Bool = true

    var noteMaxLength: Int = Int.max

    private(set) var textView: UITextView = UITextView()
    private var placeholderLabel: UILabel = UILabel()
    private var heightLayoutConstraint: NSLayoutConstraint!

    private var noteMinHeight: CGFloat = 16
    private let noteMaxHeight: CGFloat = 200
    private let noteAnimationDuration: TimeInterval = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    /// Sets up UI.
    private func setup() {
        textView.delegate = self
        textView.autocapitalizationType = .sentences
        textView.returnKeyType = .done
        textView.textContainerInset = UIEdgeInsets.zero
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear

        placeholderLabel.textColor = .Text.textSecondary
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textView)
        addSubview(placeholderLabel)

        heightLayoutConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        heightLayoutConstraint.priority = UILayoutPriority.required - 1

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -4),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightLayoutConstraint,
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 4),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -4),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor),
        ])
    }

    /// Activates view.
    func becomeActive() {
        if textView.canBecomeFirstResponder {
            textView.becomeFirstResponder()
        }
    }

    /// Updates text view UI.
    private func updateTextView(animated: Bool) {
        layoutIfNeeded()
        placeholderLabel.isHidden = !textView.text.isEmpty

        if automaticallyChangesHeight {
            TextHelper.maximize(
                textView: textView,
                heightConstraint: heightLayoutConstraint,
                minHeight: noteMinHeight,
                maxHeight: noteMaxHeight
            ) {
                UIView.animate(withDuration: animated ? noteAnimationDuration : 0, delay: 0.0, options: [],
                               animations: layoutIfNeeded, completion: nil)
                textViewHeightChangedCallback?(textView)
            }
        }
    }
	
	func set(minHeight: CGFloat) {
		self.noteMinHeight = minHeight
		
		updateTextView(animated: false)
	}

    func setPlaceholderLabelStyle(_ style: Style.Label.ColoredLabel) {
        placeholderLabel <~ style
    }

    // MARK: - UITextViewDelegate

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textViewDidBecomeActiveCallback?(textView)
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textViewFinishedEditingCallback?(textView)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textViewReturnKeyCallback != nil {
                textViewReturnKeyCallback?()
            } else {
                textViewChangedCallback?(textView)
                textView.resignFirstResponder()
            }
            return false
        } else {
            let oldText: NSString = NSString(string: textView.text)
            let newText = oldText.replacingCharacters(in: range, with: text)
            return newText.count <= noteMaxLength
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        textViewChangedCallback?(textView)
        updateTextView(animated: true)
    }
}
