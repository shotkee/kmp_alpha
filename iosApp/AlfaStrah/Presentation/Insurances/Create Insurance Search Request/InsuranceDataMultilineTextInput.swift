//
//  InsuranceDataMultilineTextInput.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 07.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class InsuranceDataMultilineTextInput: UIControl, UITextViewDelegate, EmptyHintToTopHintBottomValueAnimator {
    @IBOutlet private var idleEmptyValueHintLabel: UILabel!
    @IBOutlet private var inputModeTopHintLabel: UILabel!
    @IBOutlet private var textInput: UITextView!
    @IBOutlet private var textInputHeight: NSLayoutConstraint!

    var emptyHint: UIView {
        idleEmptyValueHintLabel
    }
    var emptySubHint: UIView? {
        nil
    }
    var topHint: UIView {
        inputModeTopHintLabel
    }
    var bottomValue: UIView {
        textInput
    }

    var textViewHeightChangedCallback: ((UITextView) -> Void)?

    struct Model {
        var isRequired: Bool
        var emptyValueHint: String?
        var topHint: String?
        var bottomHint: String?
        var value: String?
        var state: State
        var maxTextViewHeight: CGFloat

        static let empty = Model(isRequired: false, emptyValueHint: nil, topHint: nil, bottomHint: nil, value: nil,
            state: .idle, maxTextViewHeight: 20)

        enum State {
            case inputMode
            case idle
        }
    }

    private var model = Model.empty

    var value: String? {
        model.value
    }

    var text: String? {
        didSet {
            textInput.text = text
            textValueChanged(sender: textInput)
            set(state: text == nil ? .idle : .inputMode, value: model.value)
        }
    }

    func set(idleEmptyValueHint: String, inputModeTopHint: String, inputModeBottomHint: String) {
        model.bottomHint = inputModeBottomHint
        model.topHint = inputModeTopHint
        model.emptyValueHint = idleEmptyValueHint
    }

    func set(state: Model.State, value: String?) {
        switch (state, model.state) {
            case (.idle, .inputMode) where !textInput.isFirstResponder:
                animateToEmptyHint()
                model.state = state
            case (.inputMode, .idle):
                animateToTopHintBottomValue()
                model.state = state
            default:
                break
        }
        model.value = value
    }

    func set(maxTextInputHeight height: CGFloat) {
        model.maxTextViewHeight = height
    }

    @objc private func textValueChanged(sender: UITextView) {
        model.value = sender.text

        sendActions(for: .valueChanged)
        sendActions(for: .editingChanged)

        guard let text = model.value else { return }

        func sizeOfString(string: String, constrainedToWidth width: CGFloat) -> CGSize {
            NSString(string: string)
                .boundingRect(
                    with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                    attributes: [.font: textInput.font ?? UIFont.systemFont(ofSize: 16)],
                    context: nil
                )
                .size
        }

        let recommendedSize = sizeOfString(string: text, constrainedToWidth: textInput.bounds.size.width)
        let height = ceil(recommendedSize.height) + (textInput.font?.pointSize ?? 16.0)
        textInputHeight.constant = (height > model.maxTextViewHeight) ? model.maxTextViewHeight : height
        layoutIfNeeded()
        textViewHeightChangedCallback?(textInput)
    }

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapInside))

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if var existing = gestureRecognizers, !existing.isEmpty, !existing.contains(tapGestureRecognizer) {
            existing.append(tapGestureRecognizer)
            gestureRecognizers = existing
        } else {
            gestureRecognizers = [ tapGestureRecognizer ]
        }
    }

    @objc func textInputDidBeginEditing() {
        sendActions(for: .editingDidBegin)
    }

    @IBAction private func tapInside() {
        set(state: .inputMode, value: model.value)
        sendActions(for: .editingDidBegin)
        textInput.becomeFirstResponder()
    }

    func cancelEditing() {
        textInput.resignFirstResponder()
    }

    func textViewDidChange(_ textView: UITextView) {
        textValueChanged(sender: textView)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        sendActions(for: .editingDidBegin)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        sendActions(for: .editingDidEnd)

        if textInput.text?.isEmpty ?? true {
            set(state: .idle, value: nil)
        }
    }
}
