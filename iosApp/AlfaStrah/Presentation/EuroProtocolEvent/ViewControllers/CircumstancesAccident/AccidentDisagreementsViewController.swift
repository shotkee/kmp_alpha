//
//  AccidentDisagreementsViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 05.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class AccidentDisagreementsViewController: ViewController {
    struct Output {
        let save: (Bool) -> Void
    }

    struct Input {
        var hasDisagreements: Bool?
    }

    var output: Output!
    var input: Input!

    private lazy var contentStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 24

        return value
    }()

    private lazy var mainSwitchStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .vertical
        value.distribution = .fill
        value.spacing = 18

        return value
    }()

    private lazy var switchStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .fill
        value.axis = .horizontal
        value.distribution = .equalSpacing

        return value
    }()

    private lazy var switchLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value.numberOfLines = 1
        value.text = NSLocalizedString("insurance_euro_protocol_accident_contest_text", comment: "")
        value <~ Style.Label.primaryText

        return value
    }()

    private lazy var infoLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value.numberOfLines = 0
        value.text = NSLocalizedString("insurance_euro_protocol_accident_contest_info", comment: "")
        value <~ Style.Label.secondaryText

        return value
    }()

    private lazy var switcher: UISwitch = {
        let value: UISwitch = .init(frame: .zero)
        value.onTintColor = Style.Color.Palette.red

        return value
    }()

    private lazy var separatorView: HairLineView = .init()

    private lazy var saveButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)
        value.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        value.setTitle(NSLocalizedString("common_save", comment: ""), for: .normal)
        value <~ Style.RoundedButton.oldPrimaryButtonSmall

        return value
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
    }

    private func commonSetup() {
        view.addSubview(contentStackView)
        view.addSubview(saveButton)

        contentStackView.addArrangedSubview(mainSwitchStackView)
        contentStackView.addArrangedSubview(infoLabel)

        mainSwitchStackView.addArrangedSubview(switchStackView)
        mainSwitchStackView.addArrangedSubview(separatorView)

        switchStackView.addArrangedSubview(switchLabel)
        switchStackView.addArrangedSubview(switcher)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("insurance_euro_protocol_accident_contest_title", comment: "")
        switcher.setOn(input.hasDisagreements ?? false, animated: true)
    }

    @objc private func saveButtonAction() {
        output.save(switcher.isOn)
    }
}
