//
//  DesignSystemInputsViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 09.08.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class DesignSystemInputsViewController: ViewController {
    struct Input {
        let title: String
    }

    var input: Input!

    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .onDrag
        return scroll
    }()

    private var rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Style.Margins.default / 2
        return stack
    }()

    private lazy var textAreaInput: TextAreaInputField = {
        let textAreaInput = TextAreaInputField()
        let placeholder = NSLocalizedString("design_system_enter_multiline_text", comment: "")
        textAreaInput.set(title: nil, note: "", placeholder: placeholder)
        return textAreaInput
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        addTapRecognizer()
        setupViewHierarchy()
        setupUI()
    }

    private func addTapRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gesture)
    }

    private func setupViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(rootStackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: scrollView, in: view) +
                NSLayoutConstraint.fill(view: rootStackView, in: scrollView, margins: Style.Margins.defaultInsets) +
                [
                    view.widthAnchor.constraint(
                        equalTo: rootStackView.widthAnchor,
                        constant: Style.Margins.defaultInsets.left + Style.Margins.defaultInsets.right
                    )
                ]
        )
    }

    private func setupUI() {
        title = input.title
        view.backgroundColor = Style.Color.background
        addInput(textAreaInput, title: "TextArea")
    }

    private func addInput(_ input: UIView, title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel <~ Style.Label.secondaryCaption1
        rootStackView.addArrangedSubview(titleLabel)
        rootStackView.addArrangedSubview(input)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}
