//
//  CurrentPasswordViewController.swift
//  AlfaStrah
//
//  Created by vit on 20.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class CurrentPasswordViewController: ViewController {
    struct Input {
        let currentPassword: String
    }
    
    struct Output {
        let toNewPassword: () -> Void
        let forgotPassword: () -> Void
    }
    
    var input: Input!
    var output: Output!
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let actionButtonsStackView = UIStackView()
    private let continueButton = RoundEdgeButton()
    private let descriptionLabel = UILabel()
    private let passwordInput = CommonTextInput()
    private let forgotPasswordButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("current_password_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
        
        setupScrollView()
        setupContentStackView()
        setupActionButtonStackView()
        setupContinueButton()

        setupDescriptionLabel()
        setupPasswordField()
        
        setupForgotPasswordButton()
        
        updateContinueButtonState()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)

        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: scrollView, in: view))
    }
    
    private func setupContentStackView() {
        scrollView.addSubview(contentStackView)

        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 21, left: 18, bottom: 0, right: 18)
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 0
        contentStackView.backgroundColor = .clear
        contentStackView.clipsToBounds = false

        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: contentStackView, in: scrollView) +
            [ contentStackView.widthAnchor.constraint(equalTo: view.widthAnchor)]
        )
    }
    
    private func setupActionButtonStackView() {
        view.addSubview(actionButtonsStackView)

        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 9, left: 18, bottom: 18, right: 18)
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .fill
        actionButtonsStackView.axis = .vertical
        actionButtonsStackView.spacing = 0
        actionButtonsStackView.backgroundColor = .clear

        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContinueButton() {
        continueButton <~ Style.RoundedButton.oldPrimaryButtonSmall

        continueButton.setTitle(
            NSLocalizedString("common_continue", comment: ""),
            for: .normal
        )
        continueButton.addTarget(self, action: #selector(continueButtonTap), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: 48),
        ])

        actionButtonsStackView.addArrangedSubview(continueButton)
    }
    
    private func setupDescriptionLabel() {
        contentStackView.addArrangedSubview(spacer(21))
        
        descriptionLabel <~ Style.Label.secondaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = NSLocalizedString("current_password_change_description", comment: "")
        contentStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupPasswordField() {
        contentStackView.addArrangedSubview(spacer(15))
        passwordInput.textField.placeholder = NSLocalizedString("auth_password", comment: "")
		passwordInput.textField.rightViewKind = .securityButton
        passwordInput.textField.isSecureTextEntry = true
        passwordInput.textField.autocapitalizationType = .none
        passwordInput.textField.addTarget(self, action: #selector(passwordInputAllEditingEvents), for: .allEditingEvents)
        contentStackView.addArrangedSubview(passwordInput)
    }
    
    @objc func passwordInputAllEditingEvents() {
        updateContinueButtonState()
    }
    
    private func updateContinueButtonState() {
        continueButton.isEnabled = passwordInput.textField.text == input.currentPassword
    }
    
    @objc func continueButtonTap() {
        output.toNewPassword()
    }
    
    private func setupForgotPasswordButton() {
        contentStackView.addArrangedSubview(spacer(21))
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.setTitle(
            NSLocalizedString("auth_sign_in_forgot_password", comment: ""),
            for: .normal
        )
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTap), for: .touchUpInside)
        forgotPasswordButton <~ Style.Button.redLabelSmallTextButton
        
        NSLayoutConstraint.activate([
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        contentStackView.addArrangedSubview(forgotPasswordButton)
    }
    
    @objc func forgotPasswordButtonTap() {
        output.forgotPassword()
    }
}
