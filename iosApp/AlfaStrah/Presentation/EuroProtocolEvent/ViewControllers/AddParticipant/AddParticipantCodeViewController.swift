//
//  AddParticipantCodeViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 13.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class AddParticipantCodeViewController: EuroProtocolBaseViewController {
    struct Input {
        let code: UIImage
        let state: State
    }

    struct Output {
        let next: () -> Void
        let anew: () -> Void
    }

    var input: Input!
    var output: Output!

    enum State {
        case anew
        case next
    }

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 15

        return stack
    }()

    private lazy var infoLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value.numberOfLines = 2
        value.text = NSLocalizedString("insurance_euro_protocol_add_participant_code_text", comment: "")
        value.textAlignment = .center
        value <~ Style.Label.primaryText

        return value
    }()

    private lazy var codeImageView: UIImageView = UIImageView(frame: .zero)

    private lazy var buttonStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 9

        return stack
    }()

    private lazy var anewButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(anewButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_add_participant_code_anew_button_title", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var continueButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        let title = NSLocalizedString("common_continue", comment: "")
        button.setTitle(title, for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
    }

    private func commonSetup() {
        view.addSubview(contentStackView)
        view.addSubview(buttonStackView)

        contentStackView.addArrangedSubview(infoLabel)
        contentStackView.addArrangedSubview(codeImageView)

        switch input.state {
            case .anew:
                buttonStackView.addArrangedSubview(anewButton)
            case .next:
                buttonStackView.addArrangedSubview(continueButton)
        }

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            continueButton.heightAnchor.constraint(equalToConstant: 48),
            anewButton.heightAnchor.constraint(equalToConstant: 48),

            infoLabel.heightAnchor.constraint(equalToConstant: 38),

            codeImageView.heightAnchor.constraint(equalToConstant: 227),
            codeImageView.widthAnchor.constraint(equalToConstant: 227)
        ])

        codeImageView.image = input.code
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_add_participant_code_title", comment: "")
    }

    @objc private func nextButtonAction() {
        output.next()
    }

    @objc private func anewButtonAction() {
        output.anew()
    }
}
