//
//  MessageView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 26/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

import UIKit

final class MessageView: UIView {
    private var titleLabel: UILabel = UILabel()
    private var textView: UITextView = UITextView()
    private var errorLabel: UILabel = UILabel()

    var keyboardAccessoryView: UIView? {
        get {
            textView.inputAccessoryView
        }
        set {
            textView.inputAccessoryView = newValue
        }
    }

    var text: String? {
        textView.text
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }

    override var canResignFirstResponder: Bool {
        true
    }

    override func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
    }

    private func setup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))
        addGestureRecognizer(tapGestureRecognizer)

        titleLabel.text = "Номер"
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = Style.Color.grayedText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        errorLabel.numberOfLines = 0
        errorLabel.font = Style.Font.text
        errorLabel.textColor = Style.Color.errorText
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorLabel)

        textView.autocapitalizationType = .sentences
        textView.returnKeyType = .done
        textView.textContainerInset = .zero
        textView.font = Style.Font.headline1
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)

        let separator = HairLineView()
        separator.lineColor = Style.Color.separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -4),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),

            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: errorLabel.topAnchor, constant: -16),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),

            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            errorLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            separator.leadingAnchor.constraint(equalTo: errorLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    func set(title: String?, error: String? = nil) {
        titleLabel.text = title
        errorLabel.text = error
    }
}
