//
//  CreateNewPasswordViewController.swift
//  AlfaStrah
//
//  Created by vit on 08.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import IQKeyboardManagerSwift

class CreateNewPasswordViewController: ViewController,
                                       UITableViewDelegate,
                                       UITableViewDataSource {
    struct Requirement: Hashable {
        var isSatisfied: Bool
        let description: String
    }

    enum State {
        case loading
        case failure
        case data([NewPasswordRequirement]?)
    }

    struct Notify {
        let update: (_ state: State) -> Void
        let showError: (_ message: String) -> Void
    }

    private(set) lazy var notify = Notify(
        update: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(with: state)
        },
        showError: { [weak self] message in
            guard let self = self,
                  self.isViewLoaded
            else { return }
            
            self.showError(with: message)
        }
    )

    struct Input {
        let updateRequirements: () -> Void
    }

    struct Output {
        let saveNewPassword: (String) -> Void
        let toChat: () -> Void
        let retry: () -> Void
        let close: () -> Void
    }

    var input: Input!
    var output: Output!

    private let scrollView = UIScrollView()
    private let previousNextView = IQPreviousNextView()
    private let contentStackView = UIStackView()
    private let actionButtonsStackView = UIStackView()
    private let saveButton = RoundEdgeButton()
    private let operationStatusView: OperationStatusView = .init(frame: .zero)

    private let fieldsStackView = UIStackView()
    private let passwordInput = CommonTextInput()
    private let confirmPasswordInput = CommonTextInput()

    private let requirementsStackView = UIStackView()

    private let requirementsTitleLabel = UILabel()
    private let nonRegexpRequirementsStackView = UIStackView()

    private lazy var requirementsTableViewHeightConstraint: NSLayoutConstraint = {
        return requirementsTableView.heightAnchor.constraint(equalToConstant: 50)
    }()
    
    private let requirementsTableView = UITableView(frame: .zero, style: .plain)
    
    private var savePasswordErrorLabel: UILabel?
        
    private var sortedRequirements: [Requirement] = []
    private var requirements: [Requirement] = []
    
    private var validationRules: [ValidationRule] = []
    private var passwordInputIsValid = false
        
    private func updateRequirementsList() {
        if !requirements.isEmpty {
            requirementsTableView.reloadData()
            requirementsTableView.performBatchUpdates({ [weak self] in
                guard let self = self
                else { return }
                
                func ip(_ index: Int) -> IndexPath {
                    return IndexPath(row: index, section: 0)
                }
                
                for (previousPosition, requirement) in self.requirements.enumerated() {
                    if let newPosition = self.sortedRequirements.firstIndex(where: { $0.description == requirement.description }),
                       previousPosition != newPosition {
                        self.requirementsTableView.moveRow(
                            at: ip(previousPosition),
                            to: ip(newPosition)
                        )
                    }
                }
            })
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("auth_password_create_title", comment: "")
		view.backgroundColor = .Background.backgroundContent

        setupScrollView()
        setupContentStackView()
        setupActionButtonStackView()
        setupSaveButton()
        setupOperationStatusView()
        setupInputFields()
        savePasswordErrorLabel = createSavePasswordErrorLabel()
        setupRequirementsSection()
        setupRequirementsTableView()
        saveButton.isEnabled = saveButtonEnabled()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		input.updateRequirements() // completion updates collection view
	}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        requirementsTableViewHeightConstraint.constant = requirementsTableView.contentSize.height
    }
    
    // MARK: - ViewController state
    private func update(with state: State) {
        switch state {
            case .loading:
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("auth_new_user_password_requirements_loading_description", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
                
                requirementsStackView.isHidden = true
            case .failure:
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("auth_new_user_password_requirements_download_error_title", comment: ""),
                    description: NSLocalizedString("auth_new_user_password_requirements_download_error_description", comment: ""),
					icon: .Icons.cross.resized(newWidth: 32)
                ))

                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("auth_new_user_password_requirements_error_go_to_chat", comment: ""),
                        isPrimary: false,
                        action: {
                            self.output.toChat()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("auth_new_user_password_requirements_error_retry", comment: ""),
                        isPrimary: true,
                        action: {
                            self.output.retry()
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)

                addCloseButton(position: .right) { [weak self] in
                    self?.output.close()
                }
                
                requirementsStackView.isHidden = true
                
            case .data(let passwordRequirements):
                self.navigationItem.setHidesBackButton(false, animated: true)

                operationStatusView.isHidden = true
                scrollView.isHidden = false

                addRightButton(title: NSLocalizedString("auth_sign_up_chat_nav_item_title", comment: ""), action: output.toChat)
                
                requirementsStackView.isHidden = false
                
                guard let passwordRequirements = passwordRequirements
                else { return }
                
                var regexpRequirements: [Requirement] = []
                var nonRegexpRequirements: [Requirement] = []
                
                validationRules.removeAll()
                
                for requirement in passwordRequirements {
                    if let reqexp = requirement.regularExpressionString {
                        regexpRequirements.append(
                            Requirement(isSatisfied: false, description: requirement.title)
                        )
                        
                        let validationRule: ValidationRule
                        
                        switch requirement.visibilityCondition {
                            case .showAlways, .satisfiedIfPositiveResult:
                                validationRule = RegexpValidationRule(regexp: reqexp, isReverse: false)
                            case .satisfiedIfNegativeResult:
                                validationRule = RegexpValidationRule(regexp: reqexp, isReverse: true)
                        }
                    
                        validationRules.append(validationRule)
                    } else {
                        nonRegexpRequirements.append(
                            Requirement(isSatisfied: false, description: requirement.title)
                        )
                    }
                }
                
                requirements = regexpRequirements
            
                setTableHeightUsingAutolayout(  // update layout after data was loaded only - produce warning
                    tableView: requirementsTableView,
                    tableViewHeightContraint: requirementsTableViewHeightConstraint
                )
                
                sortedRequirements = requirements.sorted { !$0.isSatisfied && $1.isSatisfied }
                
                addNonRegExpRequirements(nonRegexpRequirements)
        }
    }

    private func setupOperationStatusView() {
        view.addSubview(operationStatusView)
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: view))
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)

        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: scrollView, in: view))
    }

    private func setupContentStackView() {
        scrollView.addSubview(previousNextView)

        previousNextView.addSubview(contentStackView)
        previousNextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previousNextView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            previousNextView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            previousNextView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            previousNextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            previousNextView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 21, left: 18, bottom: 0, right: 18)
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.backgroundColor = .clear
        contentStackView.clipsToBounds = false

        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: contentStackView, in: previousNextView))
    }
    
    private func createSavePasswordErrorLabel() -> UILabel {
        let savePasswordErrorLabel = UILabel()
        savePasswordErrorLabel <~ Style.Label.negativeSubhead
        savePasswordErrorLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(savePasswordErrorLabel)
        savePasswordErrorLabel.isHidden = true
        return savePasswordErrorLabel
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
            actionButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupSaveButton() {
        saveButton <~ Style.RoundedButton.primaryButtonLarge

        saveButton.setTitle(
            NSLocalizedString("common_save", comment: ""),
            for: .normal
        )
        saveButton.addTarget(self, action: #selector(saveButtonTap), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: 48),
        ])

        actionButtonsStackView.addArrangedSubview(saveButton)
    }

    @objc func saveButtonTap() {
        guard let password = passwordInput.textField.text
        else { return }
                
        output.saveNewPassword(password)
    }
    
    private func showError(with message: String) {
        guard let savePasswordErrorLabel = savePasswordErrorLabel
        else { return }
        
        savePasswordErrorLabel.text = message
        savePasswordErrorLabel.isHidden = false
    }
    
    private func hideSavePasswordError() {
        guard let savePasswordErrorLabel = savePasswordErrorLabel
        else { return }
        
        savePasswordErrorLabel.text = ""
        savePasswordErrorLabel.isHidden = true
    }

    private func setupInputFields() {
        fieldsStackView.isLayoutMarginsRelativeArrangement = true
        fieldsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        fieldsStackView.alignment = .fill
        fieldsStackView.distribution = .fill
        fieldsStackView.axis = .vertical
        fieldsStackView.spacing = 9
        fieldsStackView.backgroundColor = .clear

        fieldsStackView.translatesAutoresizingMaskIntoConstraints = false

        contentStackView.addArrangedSubview(fieldsStackView)

        passwordInput.textField.placeholder = NSLocalizedString("auth_password", comment: "")
		passwordInput.textField.rightViewKind = .securityButton
        passwordInput.textField.isSecureTextEntry = true
        passwordInput.textField.autocapitalizationType = .none
        passwordInput.textField.addTarget(self, action: #selector(passwordInputAllEditingEvents), for: .allEditingEvents)
        fieldsStackView.addArrangedSubview(passwordInput)

        confirmPasswordInput.textField.placeholder = NSLocalizedString(
            "auth_new_user_password_requirements_confirm_placeholder",
            comment: ""
        )
		confirmPasswordInput.textField.rightViewKind = .securityButton
        confirmPasswordInput.textField.isSecureTextEntry = true
        confirmPasswordInput.textField.autocapitalizationType = .none
        confirmPasswordInput.textField.addTarget(self, action: #selector(confirmPasswordInputAllEditingEvents), for: .allEditingEvents)
        fieldsStackView.addArrangedSubview(confirmPasswordInput)
    }
        
    private func handleInputsSameCharactersOnSameCount() {
        guard let passwordInputText = passwordInput.textField.text,
              let confirmPasswordInputText = confirmPasswordInput.textField.text,
              !passwordInputText.isEmpty && !confirmPasswordInputText.isEmpty,
              passwordInputText.count == confirmPasswordInputText.count
        else { return }
        
        let show = !hasSameCharacters()
        
        passwordInput.error(show: show)
        confirmPasswordInput.error(
            show: show,
            with: NSLocalizedString("auth_sign_up_text_inputs_passwords_mismatch", comment: "")
        )
    }
    
    private func hideErrors() {
        passwordInput.error(show: false)
        confirmPasswordInput.error(show: false)
        
        hideSavePasswordError()
    }
    
    @objc func passwordInputAllEditingEvents() {
        hideErrors()
        
        guard let text = passwordInput.textField.text
        else { return }
        
        passwordInputIsValid = true
        
        for (index, rule) in validationRules.enumerated() {
            switch rule.validate(text) {
                case .success:
                    requirements[index].isSatisfied = true
                case .failure:
                    requirements[index].isSatisfied = false
                    passwordInputIsValid = false
            }
        }
        
        let newSortedRequirements = requirements.sorted { !$0.isSatisfied && $1.isSatisfied }
        if sortedRequirements != newSortedRequirements {
            sortedRequirements = newSortedRequirements
            updateRequirementsList()
        }
        
        saveButton.isEnabled = saveButtonEnabled()
        
        handleInputsSameCharactersOnSameCount()
    }
    
    @objc func confirmPasswordInputAllEditingEvents() {
        hideErrors()
        
        saveButton.isEnabled = saveButtonEnabled()
        
        handleInputsSameCharactersOnSameCount()
    }
    
    private func saveButtonEnabled() -> Bool {
        return passwordInputIsValid && hasSameCharacters()
    }
    
    private func hasSameCharacters() -> Bool {
        guard let passwordText = passwordInput.textField.text,
              let confirmPasswordText = confirmPasswordInput.textField.text
        else { return false}
        
        return passwordText == confirmPasswordText
    }

    private func setupRequirementsSection() {
        requirementsStackView.isLayoutMarginsRelativeArrangement = true
        requirementsStackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        requirementsStackView.alignment = .fill
        requirementsStackView.distribution = .fill
        requirementsStackView.axis = .vertical
        requirementsStackView.spacing = 0
        requirementsStackView.backgroundColor = .clear
        requirementsStackView.clipsToBounds = false
        
        requirementsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        requirementsTitleLabel <~ Style.Label.primaryHeadline1
        requirementsTitleLabel.numberOfLines = 0
        requirementsTitleLabel.text = NSLocalizedString("auth_new_user_password_requirements_title", comment: "")
        requirementsStackView.addArrangedSubview(requirementsTitleLabel)
        
        requirementsStackView.addArrangedSubview(spacer(12))
        
        requirementsStackView.addArrangedSubview(requirementsTableView)
        
        requirementsStackView.addArrangedSubview(spacer(15))
        
        requirementsStackView.addArrangedSubview(
			spacer(1, color: .Stroke.divider).embedded()
        )
        
        requirementsStackView.addArrangedSubview(spacer(15))
        
        let cardContainerView = CardView(contentView: requirementsStackView)
		cardContainerView.contentColor = .Background.backgroundSecondary
        contentStackView.addArrangedSubview(cardContainerView)
    }
    
    private func addNonRegExpRequirements(_ requirements: [Requirement]) {
        nonRegexpRequirementsStackView.isLayoutMarginsRelativeArrangement = true
        nonRegexpRequirementsStackView.layoutMargins = .zero
        nonRegexpRequirementsStackView.alignment = .fill
        nonRegexpRequirementsStackView.distribution = .fill
        nonRegexpRequirementsStackView.axis = .vertical
        nonRegexpRequirementsStackView.spacing = 12
        nonRegexpRequirementsStackView.backgroundColor = .clear
        nonRegexpRequirementsStackView.clipsToBounds = false
        
        nonRegexpRequirementsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        requirementsStackView.addArrangedSubview(nonRegexpRequirementsStackView)
        
        for requirement in requirements {
            nonRegexpRequirementsStackView.addArrangedSubview(nonRegexpRequirement(with: requirement.description))
        }
    }
    
    private func nonRegexpRequirement(with description: String) -> UILabel {
        let requirementDescriptionLabel = UILabel()
        requirementDescriptionLabel <~ Style.Label.secondaryText
        requirementDescriptionLabel.numberOfLines = 0
        requirementDescriptionLabel.text = description
        
        return requirementDescriptionLabel
    }
    
    private func setupRequirementsTableView() {
		requirementsTableView.backgroundColor = .clear
        requirementsTableView.rowHeight = UITableView.automaticDimension
        requirementsTableView.separatorStyle = .none
        requirementsTableView.registerReusableCell(PasswordRequirementTableViewCell.id)
        
        requirementsTableView.backgroundColor = .clear
        requirementsTableView.isScrollEnabled = false
        
        requirementsTableView.translatesAutoresizingMaskIntoConstraints = false
        requirementsTableView.delegate = self
        requirementsTableView.dataSource = self
        
        NSLayoutConstraint.activate([requirementsTableViewHeightConstraint])
        
        setTableHeightUsingAutolayout(tableView: requirementsTableView, tableViewHeightContraint: requirementsTableViewHeightConstraint)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requirements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(PasswordRequirementTableViewCell.id)
                
        let requirement = requirements[indexPath.row]

        cell.configure(isSatisfied: requirement.isSatisfied, text: requirement.description)
        
        return cell
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		requirementsTableView.reloadData()
	}
}
