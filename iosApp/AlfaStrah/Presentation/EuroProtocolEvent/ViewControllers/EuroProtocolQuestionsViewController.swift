//
//  EuroProtocolQuestionsViewController
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 26.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class EuroProtocolQuestionsViewController: EuroProtocolBaseScrollViewController {
    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 30

        return stack
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 10

        return stack
    }()

    private lazy var infoLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label <~ Style.Label.secondaryText
        label.textAlignment = .left
        label.numberOfLines = 0

        return label
    }()

    private lazy var mainButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(self.mainButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_question_main_button_title", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall

        return button
    }()

    private lazy var minorButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button <~ Style.RoundedButton.oldOutlinedButtonSmall
        button.addTarget(self, action: #selector(self.minorButtonAction), for: .touchUpInside)
        button.setTitle(NSLocalizedString("insurance_euro_protocol_question_minor_button_title", comment: ""), for: .normal)

        return button
    }()

    struct Output {
        let euroProtocol: () -> Void
        let paperEuroProtocol: () -> Void
    }

    var output: Output!

    private var checkBoxViews: [CommonCheckMarkInfoView] = []

    private var isCheckedAll: Bool {
        checkBoxViews.allSatisfy { $0.isChecked }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
    }

    override func setupUI() {
        super.setupUI()

        addBottomButtonsContent(buttonsStackView)

        scrollContentView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 18),
            contentStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -18),
            contentStackView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 18),

            mainButton.heightAnchor.constraint(equalToConstant: 48),
            minorButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private struct CheckBoxData {
        let title: String
        let text: String
    }

    private func commonSetup() {
        title = NSLocalizedString("euro_protocol_process_title", comment: "")
		view.backgroundColor = .Background.backgroundContent

        infoLabel.text = NSLocalizedString("insurance_euro_protocol_question_detail", comment: "")
        contentStackView.addArrangedSubview(infoLabel)

        let checkBoxData = [
            CheckBoxData(
                title: NSLocalizedString("insurance_euro_protocol_question_1_title", comment: ""),
                text: NSLocalizedString("insurance_euro_protocol_question_1_text", comment: "")
            ),
            CheckBoxData(
                title: NSLocalizedString("insurance_euro_protocol_question_2_title", comment: ""),
                text: NSLocalizedString("insurance_euro_protocol_question_2_text", comment: "")
            ),
            CheckBoxData(
                title: NSLocalizedString("insurance_euro_protocol_question_3_title", comment: ""),
                text: NSLocalizedString("insurance_euro_protocol_question_3_text", comment: "")
            ),
            CheckBoxData(
                title: NSLocalizedString("insurance_euro_protocol_question_4_title", comment: ""),
                text: NSLocalizedString("insurance_euro_protocol_question_4_text", comment: "")
            ),
        ]

        checkBoxData.forEach {
            let view: CommonCheckMarkInfoView = .init()

            view.set(
                title: $0.title,
                text: $0.text,
                margins: Style.Margins.defaultInsets,
                appearance: .bold
            )

            view.tapHandler = { [weak self] in
                self?.updateEnableMainButton()
            }
            checkBoxViews.append(view)
        }

        checkBoxViews.forEach { contentStackView.addArrangedSubview($0) }
        [minorButton, mainButton].forEach { buttonsStackView.addArrangedSubview($0) }

        updateEnableMainButton()
    }

    private func updateEnableMainButton() {
        mainButton.isEnabled = isCheckedAll
    }

    @objc private func mainButtonAction() {
        output.euroProtocol()
    }

    @objc private func minorButtonAction() {
        output.paperEuroProtocol()
    }
}
